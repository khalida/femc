function plotCompareForecasts(allMetrics, allKWhs, forecastTypeStrings,...
    forecastMetrics, nCustomers, savePlots)

% For each type of loss plot the performance of the forecasts on the
% test data

% Plotting options:
myPaperPosition = [-0.75 -0.25 19 15];
myPaperSize = [17 14];

fig = zeros(length(forecastMetrics), 1);
nMethods = length(forecastTypeStrings);

% Set options for pretty plot
opt.BoxDim = [5.5 3];
opt.FontSize = 10;
opt.LineWidth = ones(1,7).*1;
opt.AxisLineWidth = 0.5;
opt.LineStyle={'-', '--', '-', ':', '-'};
opt.Markers = {'diamond','o','square','',''};
opt.MarkerSize = 4;
opt.YMinorTick = 'on';
opt.LegendBox = 'on';
opt.LegendBoxColor = [1, 1, 1];

whsMean = mean(allKWhs, 1).*1000;

for ii = 1:length(forecastMetrics)
    
    % Select forecast indexes to plot - here MSE and metric of interest for
    % FFNN and SARMA
    
    if strcmp('MSE', forecastMetrics{ii})
        selectedFcasts = unique([1, 2, length(forecastMetrics)+1, ...
            length(forecastMetrics)+2, nMethods]);
    else
        selectedFcasts = unique([1, ii, length(forecastMetrics)+1, ...
            length(forecastMetrics)+ii, nMethods]);
    end
    
    %% For MAPE plot absolute performance of MAPE SARMA, MAPE FFNN, NP, R
    if strcmp('MAPE', forecastMetrics{ii})
        
        selectedFcastsMAPE = [...
            find(ismember(forecastTypeStrings, 'MAPE SARMA')), ...
            find(ismember(forecastTypeStrings, 'MAPE FFNN')), ...
            find(ismember(forecastTypeStrings, 'R ETS')), ...
            find(ismember(forecastTypeStrings, 'NP'))];
        fig(ii) = figure(100 + ii);
        thisMetricMean = squeeze(mean(allMetrics(:, :,...
            selectedFcastsMAPE, ii), 1));
        thisMetricStd = squeeze(std(allMetrics(:, :, ...
            selectedFcastsMAPE, ii), [], 1));
        
        % Plot just mean for most methods
        plot(repmat(whsMean, [length(selectedFcastsMAPE)-1, 1])',...
            thisMetricMean(:,1:(end-1)), 'MarkerSize', 6);
        
        hold on
        % Plot error bars for NP
        errorbar(whsMean', thisMetricMean(:, end), ...
            thisMetricStd(:, end),'.-', 'markers', 10);
        
        ax = get(fig(ii), 'CurrentAxes');
        set(ax, 'XScale', 'log', 'YScale', 'log');
        xlabel('Mean Aggregate Demand per Interval [Wh]');
        ylabel(['Forecast Error [' forecastMetrics{ii} ']']);
        grid on;
        thisOpt = opt;
        thisOpt.LineStyle={'-', '--', ':'};
        thisOpt.LineWidth = ones(1,3).*2;
        setPlotProp(thisOpt, fig(ii));
        
        leg = legend(forecastTypeStrings(selectedFcastsMAPE), ...
            'Interpreter', 'none');
        % Increase legend vertical spacing
        leg.Position(4) = 1.25*leg.Position(4);
        % & Move down (& left) to fit in
        leg.Position(1) = leg.Position(1) - 0.1*leg.Position(3);
        leg.Position(2) = leg.Position(2) - 0.5*leg.Position(4);
        
        
        hold off;
    end
    
    
    %% For MSE also plot dabsolute performance of MSE SARMA, MSE FFNN, NP, R
    if strcmp('MSE', forecastMetrics{ii})
        
        selectedFcastsMSE = [...
            find(ismember(forecastTypeStrings, 'MSE SARMA')), ...
            find(ismember(forecastTypeStrings, 'MSE FFNN')), ...
            find(ismember(forecastTypeStrings, 'R ETS')), ...
            find(ismember(forecastTypeStrings, 'NP'))];
        fig(ii) = figure(100 + ii);
        thisMetricMean = squeeze(mean(allMetrics(:, :,...
            selectedFcastsMSE, ii), 1));
        thisMetricStd = squeeze(std(allMetrics(:, :, ...
            selectedFcastsMSE, ii), [], 1));
        
        % Plot just mean for most methods
        plot(repmat(whsMean, [length(selectedFcastsMSE)-1, 1])',...
            thisMetricMean(:,1:(end-1)), 'MarkerSize', 6);
        
        hold on
        % Plot error bars for NP
        errorbar(whsMean', thisMetricMean(:, end), ...
            thisMetricStd(:, end),'.-', 'markers', 10);
        
        ax = get(fig(ii), 'CurrentAxes');
        set(ax, 'XScale', 'log', 'YScale', 'log');
        xlabel('Mean Aggregate Demand per Interval [Wh]');
        ylabel(['Forecast Error [' forecastMetrics{ii} ']']);
        grid on;
        thisOpt = opt;
        thisOpt.LineStyle={'-', '--', ':'};
        thisOpt.LineWidth = ones(1,3).*2;
        setPlotProp(thisOpt, fig(ii));
        
        legend(forecastTypeStrings(selectedFcastsMSE), ...
            'Interpreter', 'none', 'Location', 'best');
        
        hold off;
    end
    
    
    %% Produce set of normalised plots - where losses are divided by those
    % of NP for each instance (and error metric)
    refIndex = ismember(forecastTypeStrings,'NP');
    allMetricsNormalized = allMetrics./repmat(...
        allMetrics(:,:,refIndex,:), [1, 1, nMethods, 1]);
    
    fig(ii) = figure(200 + ii);
    thisMetricMean = squeeze(mean(allMetricsNormalized(:, :, ...
        selectedFcasts(1:(end-1)), ii), 1));
    thisMetricStd = squeeze(std(allMetricsNormalized(:, :,...
        selectedFcasts(1:(end-1)), ii), [], 1));
    errorbar(repmat(whsMean, ([length(selectedFcasts(1:(end-1))), 1]))',...
        thisMetricMean, thisMetricStd,'.-', 'markers', 20);
    ax = get(fig(ii), 'CurrentAxes');
    
    legend(forecastTypeStrings(selectedFcasts(1:(end-1))),...
        'Interpreter', 'none');
    xlabel('Mean Aggregate Demand Per Interval [Wh]');
    ylabel([forecastMetrics{ii} ' relative to NP forecast'],...
        'Interpreter', 'none');
    grid on;
    
    % Fix precision
    %     yTick = get(gca,'yTick');
    %     yTickLabel = arrayfun(@(x) sprintf('%3.1f',x),yTick,...
    %         'uniformoutput', false);
    %     set(gca, 'yTickLabel', yTickLabel);
    
    setPlotProp(opt, fig(ii));
    set(ax, 'XScale', 'log');
    
    %% Produce set of normalized Box plots
    fig(ii) = figure(300 + ii);
    aboxplot(permute(allMetricsNormalized(:, :,...
        selectedFcasts(1:(end-1)),ii), [3 1 2]), 'labels',...
        nCustomers,'fclabels', ...
        forecastTypeStrings(selectedFcasts(1:(end-1))));
    
    legend(forecastTypeStrings(selectedFcasts(1:(end-1))),...
        'Interpreter', 'none');
    
    xlabel('No. of Househoulds');
    
    ylabel([forecastMetrics{ii} ' relative to NP forecast'],...
        'interpreter', 'none');
    
    grid on;
end

%% Save Figures if required
if savePlots
    
    % [Absolute MAPE plot, Rel. MSE BoxPlot, Rel PFEM BoxPlot,...
    % Rel PEMD BoxPlot]
    figureNums = [102 301 303 304];
    fileNames = {'..\results\absoluteMapePlot.pdf', ...
        '..\results\relativeMseBoxPlot', ...
        '..\results\relativePfemBoxPlot', ...
        '..\results\relativePemdBoxPlot'};
    
    for figNumIdx = 1:length(figureNums)
        figNum = figureNums(figNumIdx);
        figure(figNum);
        set(gcf, 'PaperPosition', myPaperPosition); %Position the plot further to the left and down. Extend the plot to fill entire paper.
        set(gcf, 'PaperSize', myPaperSize); %Keep the same paper size
        
        % Create vertical lines separating the groups on the box plots:
        if figNum~=102
            set(gca, 'XGrid', 'off');
            origYlims = get(gca, 'ylim');
            for xpos = [1.5 2.5 3.5]
                line([xpos xpos], origYlims, 'color', 'k');
            end
            ylim(origYlims);
            set(gca,'TickLength',[0 0])
            
            % Set Legend positions (need to fine tune based on each plot)
            leg = legend;
            if figNum==303;
                leg.Position(1) = leg.Position(1)*1.07;
                leg.Position(2) = leg.Position(2)*0.85;
            end;
            if figNum==304;
                leg.Position(1) = leg.Position(1)*1.07;
                leg.Position(2) = 0.1;
            end;
            
            % Fix precision of y axis ticks:
            %             yTick = get(gca,'yTick');
            %             yTickLabel = arrayfun(@(x) sprintf('%3.1f',x),yTick,...
            %                 'uniformoutput', false);
            %             set(gca, 'yTickLabel', yTickLabel);
        else
            % Set limits for Absolute MAPE plot
            
            %ylim([1e-2 3e0]);
            %xlim([3e2 7e5]);
        end
        
        saveas(gcf, fileNames{figNumIdx}, 'pdf');
        
    end
end

end
