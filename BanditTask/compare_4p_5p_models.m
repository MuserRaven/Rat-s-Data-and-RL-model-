function [deltaaic, bf4, bf5] = compare_4p_5p_models
%%seems to favor a single learning rate, as of 2/18/21. cmc.

[bf4, nLL4] = fit_4pmodel_macro;
[bf5, nLL5] = fit_5pmodel_macro;

%deltaaic = nan(length(nLL4),1);
deltaaic = [];
for m = 1:length(nLL4)
    nparams = length(bf4{m}(1,:));
    aic1 = 2.*nparams-2.*nLL4{m};
    
    nparams = length(bf5{m}(1,:));
    aic2 = 2.*nparams-2.*nLL5{m};
    
    deltaaic = [deltaaic; aic2-aic1];
end

figure; hist(deltaaic, 30);
[~, p] = ttest(deltaaic);
title(strcat(['p=', num2str(p)]));
set(gca, 'TickDir', 'out'); box off;
xlabel('\Delta AIC');
set(gcf, 'Color', [1 1 1]);
