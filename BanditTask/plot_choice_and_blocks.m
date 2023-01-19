function [choiceratio, idx] = plot_choice_and_blocks(S, makeplot, varargin)

wndw = 15;
[cumwr, cumwl, inc_x, inc_y] = income_choice_ratios(S, 0);
choiceratio = [];
idx = [];
plotthese = length(S.pd)-10:length(S.pd);

for j = 1:length(S.pd)
    if S.pd{j}.Stage(end)==2
        these = find(S.pd{j}.Stage==2 & S.pd{j}.vios==0);
        lprob = S.pd{j}.Pleft(these);
        rprob = S.pd{j}.Pright(these);
        wr = S.pd{j}.wr(these);
        wl = S.pd{j}.wl(these);
        lhit = S.pd{j}.lhit(these);
        rhit = S.pd{j}.rhit(these);
        
        y = smooth(wr, wndw);
        x = rprob./(rprob+lprob);
        
        
      %  if mean(abs(x-y))<=0.25
            idx = [idx; j];
            
            t = find(diff(x)~=0);
            t = [1; t+1];
            cr = nan(length(t),1);
            y2 = nan(length(x),1);
            for mk = 1:length(t)
                if mk<length(t)
                    these = (t(mk):t(mk+1)-1);
                elseif mk==length(t)
                    these = (t(mk):length(x));
                end
                
                y2(these) = nanmean(wr(these));
                cr(mk) = log2(nanmean(wr(these))/nanmean(wl(these)));
            end
            choiceratio = [choiceratio; cr];
            
            
            if makeplot==1 & ~isempty(intersect(j, plotthese))

                figure;
                
                
                subplot(1,2,1);
                plot(x, 'Color', [0 .8 1]); hold on
                plot(y, 'k');
                ylabel('P(Choose Right)');
                ylim([0 1]);
                title(strcat([S.pd{j}.RatName, ': ', S.pd{j}.SessionDate]));
                set(gcf, 'Color', [1 1 1]);
                set(gca, 'TickDir', 'out'); box off;
                
                if ~isempty(varargin)
                    pchooser = varargin{1}{j}.pchooser;
                    plot(pchooser, '--k');
                end

              %  plot(y2, 'k');
                
                subplot(1,2,2);
                plot(cumwr{j}, cumwl{j}, 'k'); hold on
                plot(inc_x{j}, inc_y{j}, 'Color', [0 .8 1]);
                set(gca, 'TickDir', 'out'); box off
                xlabel('Cumulative right choices');
                ylabel('Cumulative left choices');
                legend('Choice ratio', 'Income ratio', 'Location', 'SouthEast');
                legend('boxoff');
                set(gcf, 'Color', [1 1 1]);
                
            end
   %     end
    end
end
