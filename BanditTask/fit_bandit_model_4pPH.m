function [initcond, bestfit, nLL] = fit_bandit_model_4pPH(S, iters)
%parameters are (1)softmax, (2)lapse, (3)alpha, (4)bias. Implements
%Pearce-Hall dynamic learning rate.

data = parse_data(S);
nparams = 4;
nLL = nan(length(S.pd), 1);

for j = 1:length(data)
    
    initcond{j} = nan(iters, nparams);
    f_out = initcond;
    likey{j} = nan(iters,1);
    
    for mx = 1:iters
        
        %randomly select starting parameters.
        f = @(x) find(x==max(x));
        [initcond{j}(mx,1)] = f(rand(10,1)); %softmax
        [initcond{j}(mx,2)] = f(rand(30,1))./100; %lapse
        [initcond{j}(mx,3)] = f(rand(100,1))./100; %alpha
        [initcond{j}(mx,4)] = f(rand(100,1))./5; %l/r bias
        
        mydata.lprob = data{j}.lprob;
        mydata.rprob = data{j}.rprob;
        mydata.wr = data{j}.wr;
        mydata.lhit = data{j}.lhit;
        mydata.rhit = data{j}.rhit;
        
        [f_out{j}(mx,:), likey{j}(mx), exitflag, ~, ~, ~] = fitfun(mydata, initcond{j}(mx,:));
    end
    best = find(likey{j}==nanmin(likey{j}));
    if length(best)>1
        best = best(1);
    end
    bestfit(j,:) = f_out{j}(best,:);
    nLL(j) = likey{j}(best,:);
    
end

end

function [x_fmincon, f, exitflag, output, grad, hessianmat] = fitfun(data, x_init)

%initialize bounds, number of parameters and initial condtions
lower_bound = [0 0 0 -5];
upper_bound = [15 .3 .4 5];

obj_fun = @(x)fit_mymodel(x, data);

[x_fmincon, f, exitflag, output, ~, grad, hessianmat] = ...
    fmincon(obj_fun, x_init, [], [], [], [], lower_bound, upper_bound, [], ...
    optimset('Display', 'iter-detailed', ...
    'DiffMinChange', 0.0001, ...
    'MaxIter', 500, 'GradObj', 'off', ...
    'Algorithm', 'interior-point', 'TolX', .00001));
end


function [minimized]=fit_mymodel(param, data)

rval = nan(length(data.lprob),1);
lval = rval;
rval(1) = 0; lval(1) = 0;
mwr = rval;
pchooser = rval;

for j = 1:length(data.lprob)-1
    pchooser(j) = param(2) + (1-2*param(2))/(1+exp(-param(1)*(rval(j)-lval(j)+param(4))));
    mwr(j) = rand<pchooser(j);
    
    if data.wr(j)==1
        rew(j) = data.rhit(j);
        delta(j) = rew(j)-rval(j);
        
        rval(j+1) = rval(j)+param(3)*delta(j)*abs(delta(j));
        lval(j+1) = lval(j);
    else
        rew(j) = data.lhit(j);
        delta(j) = rew(j)-lval(j);
        
        lval(j+1) = lval(j)+param(3)*delta(j)*abs(delta(j));
        rval(j+1) = rval(j);
    end
end

likey = nan(length(rval),1);
likey(data.wr==1) = pchooser(data.wr==1);
likey(data.wr==0) = 1-pchooser(data.wr==0);
likey(likey==0) = eps;
minimized = -1.*nansum(log(likey));
end
