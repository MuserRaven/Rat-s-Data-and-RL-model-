function [pchooser, lval, rval, lprob, rprob] = model_sim(varargin)

ntrials = 10000;
blocklength = 40;
%softmax = 2.5;
lambda = 2.5; softmax = lambda;
lapse = 0;%0.025;
alpha = .3;
PH = 2;

myprobs = [.1 .8 .5 .3 .9];
rval = zeros(ntrials,1);
lval = rval;
pchooser = rval;
wr = rval;
rew = rval;
delta = rval;
lprob = rval;
rprob = rval;

if isempty(varargin)
    %randomly choose starting probabilities.
    [~, ix] = sort(rand(length(myprobs(1,:)),1));
    lprob(1:blocklength) = myprobs(ix(1));
    rprob(1:blocklength) = 1-lprob(1:blocklength);
else
    lprob = varargin{1};
    rprob = varargin{2};
end

ctr = 1;
for j = 1:ntrials
    
    if isempty(varargin)
        if ctr>=blocklength
            ctr = 0;
            [~, ix] = sort(rand(length(myprobs(1,:)),1));
            lprob(j:j+blocklength-1) = myprobs(ix(1));
            rprob(j:j+blocklength-1) = 1-lprob(j:j+blocklength-1);
        end
    end
   
    pchooser(j) = lapse + (1-2*lapse)/(1+exp(-softmax*(rval(j)-lval(j))));
    wr(j) = rand<pchooser(j);
    
    
    
    if wr(j)==1
        
        rew(j) = rand<rprob(j);
        delta(j) = rew(j)-rval(j);
       % delta(j) = delta(j)*abs(delta(j));
        
        rval(j+1) = rval(j)+alpha*delta(j);
        lval(j+1) = lval(j);
    else
        rew(j) = rand<lprob(j);
        delta(j) = rew(j)-lval(j);
      %  delta(j) = delta(j)*abs(delta(j));
        
        lval(j+1) = lval(j)+alpha*delta(j);
        rval(j+1) = rval(j);
    end
    
   % softmax = lambda/abs(delta(j));
    ctr = ctr+1;
    
end

figure;
T = 1:500;
plot(T, rprob(T)./(rprob(T) + lprob(T)), 'k'); hold on
plot(T, pchooser(T), '--k');
set(gca, 'TickDir', 'out'); box off;
ylim([0 1]);
ylabel('P(Choose Right)');
xlabel('Trial number');
set(gcf, 'Color', [1 1 1]);
