function [bf, wins, losses] = regress_prev_rews_macro

myrats = {'D001'; 'D002'; 'D003'; 'D004'};
tback = 7;

wins = nan(length(myrats), tback);
winer = wins;
losses = wins;

figure;
for m = 1:length(myrats)
    
    S = getBanditData(strcat(['select * from sess_ended where ratname = "', ...
        myrats{m},'" and end_time > "2021-02-01"']));
    data = parse_data(S);
    
    betas{m} = regress_prev_rews(S, tback);
    
    subplot(ceil(length(myrats)/2), ceil(length(myrats)/2), m);
    plot(betas{m}(:,1:tback)', 'Color', [0.5 0.5 0.8]); hold on
    plot(nanmean(betas{m}(:,1:tback)), 'Color', [0 0 1]);
    plot(betas{m}(:,tback+1:end-1)', 'Color', [0.5 0.5 0.5]); hold on
    plot(nanmean(betas{m}(:,tback+1:end-1)), 'Color', [0 0 0]);
    
    wins(m,:) = nanmean(betas{m}(:,1:tback));
    winer(m,:) = nanstd(betas{m}(:,1:tback));%./sqrt(length(betas{m}(:,1)));
    losses(m,:) = nanmean(betas{m}(:,tback+1:end-1));
   
    xlabel('Trials back');
    ylabel('Regressor');
    title(myrats{m});
    set(gca, 'TickDir', 'out'); box off;
    set(gcf, 'Color', [1 1 1]);
end

figure;
for m = 1:length(myrats)
    
    [~, bestfit, ~] = fit_exp_decay([1:tback], wins(m,:), 30);
    f = @(x) (bestfit(1)*exp(-x./bestfit(2)));

    bf{m} = bestfit;
    
    subplot(ceil(length(myrats)/2), ceil(length(myrats)/2), m);
    shadedErrorBar(1:tback, wins(m,:),winer(m,:), ...
    'lineProps', '-k'); hold on
    newy = f(1:.01:tback);
    plot(1:.01:tback, newy, '--k');
    title(strcat([(myrats{m}), '. tau = ', num2str(bestfit(2))]));
    set(gca, 'TickDir', 'out'); box off;
    set(gcf, 'Color', [1 1 1]);
    
end
