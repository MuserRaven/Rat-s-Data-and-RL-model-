function [allrt] = rt_macro
myrats = {'D001'; 'D002'; 'D003'; 'D004'};

for m = 1:length(myrats)
    S = getBanditData(strcat(['select * from sess_ended where ratname = "', ...
        myrats{m},'" and end_time > "2021-02-01"']));
    
    iters = 10;
    
    [~, bestfit, ~] = fit_bandit_model_3p(S, iters);
    [data] = gen_model_3p(S, bestfit);
    [allrt{m}, binned{m}] = RT_vs_val(S, data);
    
end

delta = nan(length(myrats), length(binned{1}.dy));
chosen = nan(length(myrats), length(binned{1}.cy));
total = nan(length(myrats), length(binned{1}.ty));
for j = 1:length(binned)
    delta(j,:) = binned{j}.dy;
    chosen(j,:) = binned{j}.cy;
    total(j,:) = binned{j}.ty;
end

figure; 
subplot(1,3,1);
ct = (binned{1}.cx(2)-binned{1}.cx(1))/2;
shadedErrorBar(binned{1}.cx-ct, nanmean(chosen), nanstd(chosen)./sqrt(length(myrats)),...
    'lineProps', '-k'); hold on
set(gca, 'TickDir', 'out'); box off
xlabel('Chosen Value');
ylabel('RT (z-scored)');

subplot(1,3,2);
tt = (binned{1}.tx(2)-binned{1}.tx(1))/2;
shadedErrorBar(binned{1}.tx-tt, nanmean(total), nanstd(total)./sqrt(length(myrats)),...
    'lineProps', '-k'); hold on
set(gca, 'TickDir', 'out'); box off
xlabel('Total Value');
ylabel('RT (z-scored)');

subplot(1,3,3);
dt = (binned{1}.dx(2)-binned{1}.dx(1))/2;
shadedErrorBar(binned{1}.dx-dt, nanmean(delta), nanstd(delta)./sqrt(length(myrats)),...
    'lineProps', '-k'); hold on
set(gca, 'TickDir', 'out'); box off
xlabel('Delta Value');
ylabel('RT (z-scored)');
