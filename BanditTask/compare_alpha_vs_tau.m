function [alpha, tau] = compare_alpha_vs_tau
myrats = {'D001'; 'D002'; 'D003'; 'D004'};

[bf, wins, losses] = regress_prev_rews_macro;
[mfit] = fit_4pmodel_macro;

tau = nan(length(myrats),1);
alpha = tau;

for j = 1:length(bf)
    tau(j) = bf{j}(2);
    alpha(j) = nanmean(mfit{j}(3));
end

figure; plot(tau, alpha, '.k', 'MarkerSize', 15); hold on
set(gca, 'TickDir', 'out'); box off
xlabel('Tau');
ylabel('Alpha');
