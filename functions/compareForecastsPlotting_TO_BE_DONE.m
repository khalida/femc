%% Load Data
allAllMetrics = zeros(9, 6, 4, 4);
allAll_kWhs = zeros(6, 4);

% fileNames = {'compareForecast_2015_06_27__1.mat', ...
%              'compareForecast_2015_06_27__10.mat', ...
%              'compareForecast_2015_06_27__100.mat', ...
%              'compareForecast_2015_06_27__1000.mat'};
% 
% % Combine results from 4 seperate runs:
% for i = 1:length(fileNames)
%     thisFile = fileNames{i};
%     load(thisFile);
%     allAllMetrics(:, :, i, :) = allMetrics;
%     allAll_kWhs(:, i) = all_kWhs;
% end
% allMetrics = allAllMetrics;
% all_kWhs = allAll_kWhs;

load('compareForecast_results_2015_06_26_FULL.mat');

savePlots = true;
plotMAPE_ABS = true;

%% Plotting

% For each type of loss plot the performance of the forecasts on the
% test data
fig = zeros(length(lossTypes), 1);

fcTypeStrings_corr = {'MSE SARMA', 'MAPE SARMA', 'PFEM SARMA', ...
    'PEMD SARMA', 'MSE FFNN', 'MAPE FFNN', 'PFEM FFNN', 'PEMD FFNN', 'NP (\pm1.0\sigma)'};

% fcTypeStrings_corr = {'MSE SARMA', 'MAPE SARMA', 'MSE FFNN', ...
%    'MAPE FFNN', 'NP'};
fcMetrics_corr = {'MSE', 'MAPE', 'PFEM', 'PEMD'};

% fcTypeStrings_corr = fcTypeStrings;
% fcMetrics_corr = fcMetrics;

% Produce pretty plot (set options)
% opt.BoxDim = [6, 3.5];
% opt.FontSize = 12;
% opt.LineWidth = [2, 2, 2, 2, 0.5];
% opt.LineStyle = {'-', '--', ':', '-.', '-'};
% opt.YMinorTick = 'on';
% opt.LegendBox = 'on';
% opt.LegendBoxColor = [1, 1, 1];

opt.BoxDim = [5.5 3];
opt.FontSize = 10;
opt.LineWidth = ones(1,7).*1;%[1, 1, 2, 2, 1, 1, 1];
opt.AxisLineWidth = 0.5;
opt.LineStyle={'-', '--', '-', ':', '-'};
opt.Markers = {'diamond','o','','',''};
% opt.MarkerSpacing = [1 1];
% opt.MarkerSize = 10;
opt.YMinorTick = 'on';
opt.LegendBox = 'on';
opt.LegendBoxColor = [1, 1, 1];

for ii = 1:length(fcMetrics)
    % Select fcast indexes to plot - here MSE and metric of interest for
    % FFNN and SARMA
    % selectedFcasts = 1:length(fcTypeStrings);
    if(ii == 1)
        selectedFcasts = unique([1, 2, length(fcMetrics)+1, ...
            length(fcMetrics)+2, length(fcTypeStrings)]);
    else
        selectedFcasts = unique([1, ii, length(fcMetrics)+1, ...
            ii+length(fcMetrics), length(fcTypeStrings)]);
    end
    
    % Plot points averaged over all aggregates with same number of customers
    
    if plotMAPE_ABS
        
        if strcmp('MAPE', fcMetrics{ii})
            % Plot just MAPE-SARMA, MAPE-FFNN, and naivePeriodic
            selectedFcastsMAPE = [2, 6, 9];
            fig(ii) = figure(200 + ii);
            thisMetric_mean = squeeze(mean(allMetrics(selectedFcastsMAPE, :, :, ii), 2));
            thisMetric_std = squeeze(std(allMetrics(selectedFcastsMAPE, :, :, ii), [], 2));
            Whs_mean = mean(all_kWhs, 1).*1000;
            
            % Plot just mean for most methods
            plt = plot(repmat(Whs_mean, [length(selectedFcastsMAPE)-1, 1])',...
                thisMetric_mean(1:(end-1),:)', 'MarkerSize', 10);
            
            hold on
            % Plot error bars for NP
            errorbar(Whs_mean', thisMetric_mean(end, :)', ...
                thisMetric_std(end, :)','.-', 'markers', 10);
            
            ax = get(fig(ii), 'CurrentAxes');
            set(ax, 'XScale', 'log', 'YScale', 'log');
            leg = legend(fcTypeStrings_corr(selectedFcastsMAPE));
            % Increase legend vertical spacing
            leg.Position(4) = 1.25*leg.Position(4);
            % & Move down (& left) to fit in
            leg.Position(1) = leg.Position(1) - 0.1*leg.Position(3);
            leg.Position(2) = leg.Position(2) - 0.5*leg.Position(4);
            
            xlabel('Mean Aggregate Demand per Interval [Wh]');
            ylabel(['Forecast Error [' fcMetrics_corr{ii} ']']);
            grid on;
            
            setPlotProp(opt, fig(ii));
            
            plt(1).MarkerSize = 5;
            plt(2).MarkerSize = 5;
            
            hold off;
            
        end
        
    end
    %     fig = figure(300 + ii);
    %     plot(kWhs_mean, thisMetric_mean, 'LineWidth', 5);
    %     ax = get(fig, 'CurrentAxes');
    
    %     title(['Plot of averaged ' fcMetrics{ii} ' VS Aggregation Size']);
    %     legend(fcTypeStrings(selectedFcasts), 'interpreter', 'none');
    %     xlabel('Average Aggregate Demand [kWh/time-step] (for each # customer aggregate)');
    %     ylabel(['Averaged ' fcMetrics{ii}]);
    %     grid on;
    
    % Produce a set of normalised plots - where losses are divided by those
    % of naive periodic for each instance:
    refIndex =find(ismember(fcTypeStrings,'naivePeriodic'));
    
    allMetrics_norm = allMetrics./repmat(allMetrics(refIndex,:,:,:), ...
        [nMethods, 1, 1, 1]);
    
    %     % Plot points averaged over all aggregates with same number of customers
    %     fig(ii) = figure(400 + ii);
    %     thisMetric_mean = squeeze(mean(allMetrics_norm(selectedFcasts(1:(end-1)), :, :, ii), 2));
    %     thisMetric_std = squeeze(std(allMetrics_norm(selectedFcasts(1:(end-1)), :, :, ii), [], 2));
    %     errorbar(repmat(Whs_mean, [length(selectedFcasts(1:(end-1))), 1])', thisMetric_mean', ...
    %         thisMetric_std'./2,'.-', 'markers', 20);
    %     ax = get(fig(ii), 'CurrentAxes');
    %
    %     % Relabel fcTypeStrings to assist plotting:
    
    %
    %     legend(fcTypeStrings_corr(selectedFcasts(1:(end-1))), 'interpreter', 'none');
    %     xlabel('Mean Aggregate Demand Per Time-step (Wh)');
    %     ylabel([fcMetrics_corr{ii} ' relative to NP forecast'], 'interpreter', 'none');
    %     grid on;
    %
    %     % Fix precision
    %     yTick = get(gca,'yTick');
    %     yTickLabel = arrayfun(@(x) sprintf('%3.1f',x),yTick,...
    %         'uniformoutput', false);
    %     set(gca, 'yTickLabel', yTickLabel);
    %
    %     setPlotProp(opt, fig(ii));
    %     set(ax, 'XScale', 'log');
    
    % Boxplot
    fig(ii) = figure(600 + ii);
    if true%~strcmp('MAPE', fcMetrics{ii})
        aboxplot(allMetrics_norm(selectedFcasts(1:(end-1)), :, :, ii), ...
            'labels', numCustomers,'fclabels', ...
            fcTypeStrings_corr(selectedFcasts(1:(end-1))));
    end
    
    ax = get(fig(ii), 'CurrentAxes');
    %     legend(fcTypeStrings_corr(selectedFcasts(1:(end-1))), 'interpreter', 'none');
    xlabel('No. of Househoulds');
    ylabel([fcMetrics_corr{ii} ' relative to NP forecast'], 'interpreter', 'none');
    grid on;
    
end

%% save figures:
if savePlots
    
    fileNames = {'2015_06_27_MSE_4_fcast_comparison_simple', ...
        '2015_06_27_MAPE_4_fcast_comparison_simple', ...
        '2015_06_27_PFEM_4_fcast_comparison_simple', ...
        '2015_06_27_PEMD_4_fcast_comparison_simple', ...
        '2015_06_27_MAPE_ABS_comparison_simple'};
    
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
            % if figNum==602; leg.Position(2) = 0.15; end;
            if figNum==603;
                leg.Position(1) = leg.Position(1)*1.07;
                leg.Position(2) = leg.Position(2)*1.07;
            end;
            if figNum==604;
                leg.Position(1) = leg.Position(1)*1.07;
                leg.Position(2) = 0.1;
            end;
            
            % Fix precision
            yTick = get(gca,'yTick');
            yTickLabel = arrayfun(@(x) sprintf('%3.1f',x),yTick,...
                'uniformoutput', false);
            %             if figNum==603 % || figNum==604
            %                 yTickLabel = arrayfun(@(x) sprintf('%3.2f',x),yTick,...
            %                     'uniformoutput', false);
            %                 set(gcf, 'PaperPosition', [-1 -0.25 19.75 15]);
            %             end
            set(gca, 'yTick', yTick);
            set(gca, 'yTickLabel', yTickLabel);
            
        else
            ylim([1e-2 3e0]);
            xlim([3e2 7e5]);
            set(gcf, 'PaperPosition', [-0.15 -0.15 13.9 10.9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
            set(gcf, 'PaperSize', [13 10]); %Keep the same paper size
        end
        
        saveas(gcf, fileNames{figNumIdx}, 'pdf');
    end
end
