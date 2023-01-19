function [data] = gen_model_5p(S, bestfit)
%parameters are (1)softmax, (2)lapse, (3)alpha_gain, (4)bias, (5)alpha_loss

data = parse_data(S);

for mx = 1:length(data)
    param =  bestfit(mx,:);
    
    rval = nan(length(data{mx}.lprob),1);
    lval = rval;
    rval(1) = 0; lval(1) = 0;
    data{mx}.mwr = rval;
    data{mx}.pchooser = rval;
    
    for j = 1:length(data{mx}.lprob)-1
        data{mx}.pchooser(j) = param(2) + (1-2*param(2))/(1+exp(-param(1)*(rval(j)-lval(j)+param(4))));
        data{mx}.mwr(j) = rand<data{mx}.pchooser(j);
        
        if data{mx}.wr(j)==1
            rew(j) = data{mx}.rhit(j);
            delta(j) = rew(j)-rval(j);
            
            if delta(j)>=0
                rval(j+1) = rval(j)+param(3)*delta(j);
            else
                rval(j+1) = rval(j)+param(5)*delta(j);
            end
            lval(j+1) = lval(j);
        else
            rew(j) = data{mx}.lhit(j);
            delta(j) = rew(j)-lval(j);
            
            if delta(j)>=0
                lval(j+1) = lval(j)+param(3)*delta(j);
            else
                lval(j+1) = lval(j)+param(5)*delta(j);
            end
            rval(j+1) = rval(j);
        end
    end
end
