function [allrt, binned] = RT_vs_val(S, data)

allrt = [];
lval = [];
rval = [];
cval = [];
tval = [];
dval = [];

for j = 1:length(S.pd)
    rt{j} = nan(length(S.pd{j}.wr), 1);
    for k = 1:length(S.peh{j})
        rt{j}(k) = S.peh{j}(k).States.WaitForSidePoke(2)-...
            S.peh{j}(k).States.WaitForSidePoke(1);
    end
    goods = find(S.pd{j}.vios==0);
    rt{j} = (rt{j}-nanmean(rt{j}))./nanstd(rt{j}); %z-score each session
    allrt = [allrt; rt{j}(goods)];
    lval = [lval; data{j}.lval];
    rval = [rval; data{j}.rval];
    chosen = data{j}.rval.*data{j}.wr + data{j}.lval.*data{j}.wl;
    cval = [cval; chosen];
    tval = [tval; data{j}.rval + data{j}.lval];
    unchosen = data{j}.rval.*data{j}.wl + data{j}.lval.*data{j}.wr;
    dval = [dval; chosen-unchosen];
end


x = [0:.1:1];
cy = nan(1,length(x)); cyer = cy;
dy = cy; dyer = cy;
for j = 2:length(x)
    these = find(cval>=x(j-1)&cval<x(j));
    cy(j) = nanmean(allrt(these));
    cyer(j) = nanstd(allrt(these))./sqrt(length(these));
   
end
binned.cx = x;
binned.cy = cy;
binned.cyer = cyer;

tx = [0:.2:nanmax(tval)];
ty = nan(1, length(tx)); tyer = ty;
for j = 2:length(tx)
    these = find(tval>=tx(j-1)&tval<tx(j));
    ty(j) = nanmean(allrt(these));
    tyer(j) = nanstd(allrt(these))./sqrt(length(these));
end
binned.tx = tx;
binned.ty = ty;

dx = [nanmin(dval):.2:nanmax(dval)];
dy = nan(1, length(dx)); dyer = dy;
for j = 2:length(dx)
    these = find(dval>=dx(j-1)&dval<dx(j));
    dy(j) = nanmean(allrt(these));
    dyer(j) = nanstd(allrt(these))./sqrt(length(these));
end
binned.dx = dx;
binned.dy = dy;

figure; 
subplot(1,3,1);
shadedErrorBar(x-.05, cy, cyer, 'lineProps', '-k'); hold on
set(gca, 'TickDir', 'out'); box off
ylabel('RT (s)');
xlabel('Chosen value');
title(S.pd{end}.RatName);

subplot(1,3,2);
dt = (tx(2)-tx(1))./2;
shadedErrorBar(tx-dt, ty, tyer, 'lineProps', '-k'); hold on
set(gca, 'TickDir', 'out'); box off
ylabel('RT (s)');
xlabel('Total value');
title(S.pd{end}.RatName);

subplot(1,3,3);
dt = (dx(2)-dx(1))./2;
shadedErrorBar(dx+dt, dy, dyer, 'lineProps', '-k'); hold on
set(gca, 'TickDir', 'out'); box off
ylabel('RT (s)');
xlabel('Delta value');
title(S.pd{end}.RatName);
