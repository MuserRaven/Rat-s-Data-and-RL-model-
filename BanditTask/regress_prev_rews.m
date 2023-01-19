function [betas] = regress_prev_rews(S, tback)

data = parse_data(S);
betas = nan(length(data), tback*2+1);

for mx = 1:length(data)
    
    x = zeros(length(data{mx}.wr),1);
    xmiss = x;
    
    these = find(data{mx}.wr==1 & data{mx}.rhit==1);
    x(these) = 1;
    
    these = find(data{mx}.wr==1 & data{mx}.rhit==0);
    xmiss(these) = -1;
    
    these = find(data{mx}.wr==0 & data{mx}.lhit==1);
    x(these) = -1;
    
    these = find(data{mx}.wr==0 & data{mx}.lhit==0);
    xmiss(these) = 1;
    
    X = x;
    Xmiss = xmiss;
    
    for j = 1:tback
        x = [x, [zeros(j,1); X(1:end-j)]];
        xmiss = [xmiss, [zeros(j,1); Xmiss(1:end-j)]];
    end
    x = [x(:,2:end), xmiss(:,2:end), ones(length(data{mx}.wr),1)];
    
    y = data{mx}.wr;
    b = regress(y,x);
    betas(mx,:) = b';
    
end
