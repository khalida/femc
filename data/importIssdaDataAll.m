% file: importIssdaDataAll.m
% auth: Khalid Abdulla
% date: 26/10/2015
% brief: Import data of interest from ISSDA data set
%            requires care as text files >400MB.
% ver: Extended to import all data and extract only residential customers

clearvars; close all; clc;
doPlots = true;
tic;

%% Data settings
fileStrings = {'File1.txt', 'File2.txt', 'File3.txt', 'File4.txt',...
    'File5.txt', 'File6.txt'};

% Get all row lengths
nLinesPerFile = zeros(length(fileStrings), 1);
disp('=== Get size of each file ===');
for fileStringIdx = 1:length(fileStrings)
    fileID = fopen(fileStrings{fileStringIdx});
    %% Ascertain number of lines:
    %# Get file size.
    fseek(fileID, 0, 'eof');
    fileSize = ftell(fileID);
    frewind(fileID);
    
    %# Read the whole file, as bytes (ASCI characters)
    tempdata = fread(fileID, fileSize, 'uint8');
    
    %# Count number of line-feeds, to get nRows
    % (assumes there is blank line at end of file, as was the case)
    nLinesPerFile(fileStringIdx) = sum(tempdata == 10);
    
    clear tempdata
    fclose(fileID);
end
totalLines = sum(nLinesPerFile);

% Pre-allocate cellarray to hold all of the data:
data = cell(3, 1);
data{1} = zeros(totalLines,1,'int32');
data{2} = zeros(totalLines,1,'int32');
data{3} = zeros(totalLines,1,'double');

% Read in values as integer (meter_ID), integer (day-time code), kWh used.
formatSpec = '%d %d %f';

disp('=== Read raw data ===');
fromLine = 1;
for fileStringIdx = 1:length(fileStrings)
    fileID = fopen(fileStrings{fileStringIdx});
    
    % The below results in struct, with:
    % tempdata{1} having meter_ID
    % tampdata{2} having time_index
    % tempdata{3} having kWh in that 0.5-hour interval
    tempdata = textscan(fileID,formatSpec,nLinesPerFile(fileStringIdx),...
        'Delimiter','\n');
    
    for colNum = 1:3
        data{colNum}(fromLine:(fromLine+nLinesPerFile(fileStringIdx)-1))...
            = tempdata{colNum};
    end
    
    clear tempdata;
    fromLine = fromLine + nLinesPerFile(fileStringIdx);
    fclose(fileID);
end
toc;

disp('=== Get No. of reads from each meter ===');
uniqueMeters = unique(data{1});
meterHistoricReads = zeros(length(uniqueMeters), 1);
for ii = 1:length(uniqueMeters)
    meterHistoricReads(ii) = sum(data{1} == uniqueMeters(ii));
end

% Extract data for the all meters which have 25730 records (the
% most common large number of historic reads); corresponds to over 1 year
longReadLength = 25730;

uniqueMetersLongRead = uniqueMeters(meterHistoricReads == ...
    longReadLength);

% Extract only residential data:
residentialIDs = getResidentialMeterIDs();

% Get indexes to keep (residential and of correct length):
rowsToKeep = ismember(data{1}, residentialIDs) & ...
    ismember(data{1}, uniqueMetersLongRead);

disp('=== Extract data for residential meters, with large No. reads ===');
data{1} = data{1}(rowsToKeep);
data{2} = data{2}(rowsToKeep);
data{3} = data{3}(rowsToKeep);

% Update list of unique meters, to include only residential ones:
uniqueMetersLongRead = unique(data{1});

% NB: it is necessary to cast type to double to prevent kWh float being
% cast to integers
demandData = [double(data{1}), double(data{2}), double(data{3})];

% Remove old data file to free up memory
clear data;

% Extract each meter reading into separate page of 3-d matrix, and sort
% into time order
disp('=== Colect data by meter ID ===');
meterReads = zeros(longReadLength, 3,  length(uniqueMetersLongRead));
for ii = 1:length(uniqueMetersLongRead)
    meterReads(:, :, ii) = demandData(demandData(:, 1) == ...
        uniqueMetersLongRead(ii), :);
    meterReads(:, :, ii) = sortrows(meterReads(:, :, ii), 2);
end

disp('=== Plotting ===');
if doPlots
    % Plot a series for each meter
    figure(1); %#ok<*UNRCH>
    plot(squeeze(meterReads(:, 3, :)));
    xlabel('Time [daycode-hrcode]');
    ylabel('Energy Use by Meter [kWh/time-step]');
    
    % sum together all these meters
    sumMeterReads = sum(meterReads(:, 3, :), 3);
    
    % Plot this sum
    figure(2);
    plot(sumMeterReads);
    xlabel('Time [daycode-hrcode]');
    ylabel('Total Energy Use [kWh/time-step]');
    
end

disp('=== Format data into [nMeters x nReads] matrix ===');
disp('nMeters: '); disp(length(uniqueMetersLongRead));
disp('nReads: '); disp(longReadLength);

demandData = squeeze(meterReads(:, 3, :));

%% Save demandData variable:
% Filename is so labelled because the above analysis should result in
% 3,639 meters being extracted from the original data set
save('demand_3639.mat', 'demandData', '-v7.3');

toc;
