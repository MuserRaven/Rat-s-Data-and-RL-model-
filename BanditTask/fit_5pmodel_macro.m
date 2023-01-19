function [bf, nLL] = fit_5pmodel_macro
%parameters are (1)softmax, (2)lapse, (3)alpha_gain, (4)bias, (5)alpha_loss

myrats = {'D001'; 'D002'; 'D003'; 'D004'};

for m = 1:length(myrats)
    S = getBanditData(strcat(['select * from sess_ended where ratname = "', ...
        myrats{m},'" and end_time > "2021-02-01"']));
    
    iters = 10;
    
    [initcond, bestfit, nLL{m}] = fit_bandit_model_5p(S, iters);
    [data] = gen_model_5p(S, bestfit);
    bf{m} = bestfit;
    if m==4
        plot_choice_and_blocks(S, data);
    end
end

figure; 
subplot(1,2,1);
mycolors = [0 0 0; 1 0 0; 0 .6 0; 0 0 1];
for m = 1:length(myrats)
    for j = 1:length(bf{m}(:,1))
        sc = scatter(bf{m}(j,3), bf{m}(j,1), 'MarkerFaceColor', mycolors(m,:), ...
            'MarkerEdgeColor', mycolors(m,:)); hold on
        sc.MarkerFaceAlpha = .2;
        sc.MarkerEdgeAlpha = .2;
    end
    
    x1 = nanmean(bf{m}(:,3))-nanstd(bf{m}(:,3));
    x2 = nanmean(bf{m}(:,3))+nanstd(bf{m}(:,3));
    y1 = nanmean(bf{m}(:,1))-nanstd(bf{m}(:,1));
    y2 = nanmean(bf{m}(:,1))+nanstd(bf{m}(:,1));
    line([x1 x2], [nanmean(bf{m}(:,1)) nanmean(bf{m}(:,1))], 'Color', mycolors(m,:));
    line([nanmean(bf{m}(:,3)) nanmean(bf{m}(:,3))], [y1 y2], 'Color', mycolors(m,:));
   % plot(nanmean(bf{m}(:,3)), nanmean(bf{m}(:,1)), '+', 'Color', mycolors(m,:)); hold on
end
xlabel('alpha'); ylabel('softmax');
%ylim([0 9]);
set(gca, 'TickDir', 'out'); box off;

subplot(1,2,2);
for m = 1:length(myrats)
    for j = 1:length(bf{m}(:,1))
        sc = scatter(bf{m}(j,4), bf{m}(j,2), 'MarkerFaceColor', mycolors(m,:), ...
            'MarkerEdgeColor', mycolors(m,:)); hold on
        sc.MarkerFaceAlpha = .2;
        sc.MarkerEdgeAlpha = .2;
    end
    x1 = nanmean(bf{m}(:,4))-nanstd(bf{m}(:,4));
    x2 = nanmean(bf{m}(:,4))+nanstd(bf{m}(:,4));
    y1 = nanmean(bf{m}(:,2))-nanstd(bf{m}(:,2));
    y2 = nanmean(bf{m}(:,2))+nanstd(bf{m}(:,2));
    line([x1 x2], [nanmean(bf{m}(:,2)) nanmean(bf{m}(:,2))], 'Color', mycolors(m,:));
    line([nanmean(bf{m}(:,4)) nanmean(bf{m}(:,4))], [y1 y2], 'Color', mycolors(m,:));
end
xlabel('bias'); ylabel('lapse');
set(gca, 'TickDir', 'out'); box off;
set(gcf, 'Color', [1 1 1]);

figure; 
x = 1:length(bf{1}(1,:));
for m = 1:length(myrats)
    subplot(2,2,m);
    imagesc(cov(bf{m}));
    set(gca, 'xTick', x); 
    set(gca, 'yTick', x);
    set(gca, 'xTickLabels', {'softmax'; 'lapse'; 'alpha'; 'bias'});
    set(gca, 'yTicklabels', {'softmax'; 'lapse'; 'alpha'; 'bias'});
    title(myrats{m});
end
set(gcf, 'Color', [1 1 1]);
