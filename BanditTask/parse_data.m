function data = parse_data(S)

for j = 1:length(S.pd)
    if S.pd{j}.Stage(end)==2
        these = find(S.pd{j}.Stage==2 & S.pd{j}.vios==0);
        data{j}.lprob = S.pd{j}.Pleft(these);
        data{j}.rprob = S.pd{j}.Pright(these);
        data{j}.wr = S.pd{j}.wr(these);
        data{j}.wl = S.pd{j}.wl(these);
        data{j}.lhit = S.pd{j}.lhit(these);
        data{j}.rhit = S.pd{j}.rhit(these);
    end
end     
