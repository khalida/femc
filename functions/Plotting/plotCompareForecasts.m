function plotCompareForecasts(allMetrics, allKWhs, forecastTypeStrings,...
    forecastMetrics, nCustomers, savePlots, fileNames)

% For each type of loss plot the performance of the forecasts on the
% test data
fig = zeros(length(forecastMetrics), 1);
nMethods = length(forecastTypeStrings);

% Set options for pretty plot
opt.BoxDim = [5.5 3];
opt.FontSize = 10;
opt.LineWidth = ones(1,7).*1;%[1, 1, 2, 2, 1, 1, 1];
opt.AxisLineWidth = 0.5;
opt.LineStyle={'-', '--', '-', ':', '-'};
opt.Markers = {'diamond','o','','',''};
opt.MarkerSpacing = [1 1];
opt.MarkerSize = 10;
opt.YMinorTick = 'on';
opt.LegendBox = 'on';
opt.LegendBoxColor = [1, 1, 1];

whsMean = mean(allKWhs, 1).*1000;

for ii = 1:length(forecastMetrics)
    % Select forecast indexes to plot - here MSE and metric of interest for
    % FFNN and SARMA
    
    if strcmp('MSE', forecastMetrics{ii})
        selectedFcasts = unique([1, 2, length(forecastMetrics)+1, ...
            length(forecastMetrics)+2, length(forecastTypeStrings)]);
    else
        selectedFcasts = unique([1, ii, length(forecastMetrics)+1, ...
            length(forecastMetrics)+ii, length(forecastTypeStrings)]);
    end
    
    % Plot points averaged over all aggregates with same nCustomers
    
    if strcmp('MAPE', forecastMetrics{ii})
        % For MAPE comparison plot absolute peformance of
        % MAPE SARMA, MAPE FFNN, and NP
        selectedFcastsMAPE = [ii, ii+length(forecastMetrics),...
            length(forecastTypeStrings)];
        fig(ii) = figure(100 + ii);
        thisMetricMean = squeeze(mean(allMetrics(:, :,...
            selectedFcastsMAPE, ii), 1));
        thisMetricStd = squeeze(std(allMetrics(:, :, ...
            selectedFcastsMAPE, ii), [], 1));
        
        % Plot just mean for most methods
        plt = plot(repmat(whsMean, [length(selectedFcastsMAPE)-1, 1])',...
            thisMetricMean(:,1:(end-1)), 'MarkerSize', 10);
        
        hold on
        % Plot error bars for NP
        errorbar(whsMean', thisMetricMean(:, end), ...
            thisMetricStd(:, end),'.-', 'markers', 10);
        
        ax = get(fig(ii), 'CurrentAxes');
        set(ax, 'XScale', 'log', 'YScale', 'log');
        leg = legend(forecastTypeStrings(selectedFcastsMAPE));
        % Increase legend vertical spacing
        leg.Position(4) = 1.25*leg.Position(4);
        % & Move down (& left) to fit in
        leg.Position(1) = leg.Position(1) - 0.1*leg.Position(3);
        leg.Position(2) = leg.Position(2) - 0.5*leg.Position(4);
        
        xlabel('Mean Aggregate Demand per Interval [Wh]');
        ylabel(['Forecast Error [' forecastMetrics{ii} ']']);
        grid on;
        
        setPlotProp(opt, fig(ii));
        
        plt(1).MarkerSize = 5;
        plt(2).MarkerSize = 5;
        
        hold off;
        
    end
    
    % Produce set of normalised plots - where losses are divided by those
    % of NP for each instance (and error metric)
    refIndex = ismember(forecastTypeStrings,'NP');
    allMetricsNormalized = allMetrics./repmat(...
        allMetrics(:,:,refIndex,:), [1, 1, nMethods, 1]);
    
    % Plot points averaged over all aggregates with same nCustomers
    fig(ii) = figure(200 + ii);
    thisMetricMean = squeeze(mean(allMetricsNormalized(:, :, ...
        selectedFcasts(1:(end-1)), ii), 1));
    thisMetricStd = squeeze(std(allMetricsNormalized(:, :,...
        selectedFcasts(1:(end-1)), ii), [], 1));
    errorbar(repmat(whsMean, ([length(selectedFcasts(1:(end-1))), 1]))',...
        thisMetricMean, thisMetricStd,'.-', 'markers', 20);
    ax = get(fig(ii), 'CurrentAxes');
    
    legend(forecastTypeStrings(selectedFcasts(1:(end-1))),...
        'interpreter', 'none');
    xlabel('Mean Aggregate Demand Per Time-step (Wh)');
    ylabel([forecastMetrics{ii} ' relative to NP forecast'],...
        'interpreter', 'none');
    grid on;
    
    % Fix precision
    %     yTick = get(gca,'yTick');
    %     yTickLabel = arrayfun(@(x) sprintf('%3.1f',x),yTick,...
    %         'uniformoutput', false);
    %     set(gca, 'yTickLabel', yTickLabel);
    
    setPlotProp(opt, fig(ii));
    set(ax, 'XScale', 'log');
    
    if ~strcmp('MAPE', forecastMetrics{ii})
        % Boxplot
        fig(ii) = figure(300 + ii);
        aboxplot(permute(allMetricsNormalized(:, :,...
            selectedFcasts(1:(end-1)),ii), [3 1 2]), 'labels',...
            nCustomers,'fclabels', ...
            forecastTypeStrings(selectedFcasts(1:(end-1))));
        
        legend(forecastTypeStrings(selectedFcasts(1:(end-1))),...
            'interpreter', 'none');
        xlabel('No. of Househoulds');
        ylabel([forecastMetrics{ii} ' relative to NP forecast'],...
            'interpreter', 'none');
        grid on;
    end
end

% TODO: Need to tidy up the savePlots part of this code

% save figures:
if savePlots
    
    figureNums = [601 602 603 604 202];
    
    for figNumIdx = 1:length(figureNums)
        figNum = figureNums(figNumIdx);
        figure(figNum);
        set(gcf, 'PaperPosition', [-1.25 -0.25 20 15]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
        set(gcf, 'PaperSize', [17 14]); %Keep the same paper size
        
        if figNum~=202
            % Create vertical lines separating the groups
            set(gca, 'XGrid', 'off');
            orig_ylims = get(gca, 'ylim');
            for xpos = [1.5 2.5 3.5]
                line([xpos xpos], orig_ylims, 'color', 'k');
            end
            ylim(orig_ylims);
            set(gca,'TickLength',[0 0])
            
            % Set Legend positions:
            leg = legend;
            if figNum==602; leg.Position(2) = 0.15; end;
            if figNum==603;
                leg.Position(1) = leg.Position(1)*1.07;
                leg.Position(2) = leg.Position(2)*1.07;
            end;
            if figNum==604;
                leg.Position(1) = leg.Position(1)*1.07;
                leg.Position(2) = 0.1;
            end;
            
            % Fix precision
            %             yTick = get(gca,'yTick');
            %             yTickLabel = arrayfun(@(x) sprintf('%3.1f',x),yTick,...
            %                 'uniformoutput', false);
            %             if figNum==603 % || figNum==604
            %                 yTickLabel = arrayfun(@(x) sprintf('%3.2f',x),yTick,...
            %                     'uniformoutput', false);
            %                 set(gcf, 'PaperPosition', [-1 -0.25 19.75 15]);
            %             end
            %             set(gca, 'yTick', yTick);
            %             set(gca, 'yTickLabel', yTickLabel);
            
        else
            ylim([1e-2 3e0]);
            xlim([3e2 7e5]);
            set(gcf, 'PaperPosition', [-0.15 -0.15 13.9 10.9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
            set(gcf, 'PaperSize', [13 10]); %Keep the same paper size
        end
        
        saveas(gcf, fileNames{figNumIdx}, 'pdf');
    end
end
