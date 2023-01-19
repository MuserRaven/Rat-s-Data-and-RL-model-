function [deltaaic, bf4, bfPH] = compare_4p_PH_models
%%compare the 4-parameter (softmax, lapse, alpha, bias) model to a similar
%%one that implements a Pearce-Hall dynamic learning rate. cmc 2/19/21.

[bf4, nLL4] = fit_4pmodel_macro;
[bfPH, nLLPH] = fit_4p_PHmodel_macro;

%deltaaic = nan(length(nLL4),1);
deltaaic = [];
for m = 1:length(nLL4)
    nparams = length(bf4{m}(1,:));
    aic1 = 2.*nparams-2.*nLL4{m};
    
    nparams = length(bfPH{m}(1,:));
    aic2 = 2.*nparams-2.*nLLPH{m};
    
    deltaaic = [deltaaic; aic2-aic1];
end

figure; hist(deltaaic, 30);
[~, p] = ttest(deltaaic);
title(strcat(['p=', num2str(p)]));
set(gca, 'TickDir', 'out'); box off;
xlabel('\Delta AIC');
set(gcf, 'Color', [1 1 1]);
