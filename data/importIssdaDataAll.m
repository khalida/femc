% file: importIssdaDataAll.m
% auth: Khalid Abdulla
% date: 26/10/2015
% brief: Import data of interest from ISSDA data set
%            requires care as text files >400MB.
% ver: Extended to import all data and extract only residential customers

clearvars; close all; clc;
tic;

%% Data settings
fileStrings = {'File1.txt', 'File2.txt', 'File3.txt', 'File4.txt',...
    'File5.txt', 'File6.txt'};

formatSpec = '%d %d %f';

% Get all row lengths
nLines = zeros(length(fileStrings), 1);
for fileStringIdx = 1:length(fileStrings)
    fileID = fopen(fileStrings{fileStringIdx});
    %% Ascertain number of lines:
    %# Get file size.
    fseek(fileID, 0, 'eof');
    fileSize = ftell(fileID);
    frewind(fileID);
    %# Read the whole file.
    data = fread(fileID, fileSize, 'uint8');
    %# Count number of line-feeds and increase by one.
    nLines(fileStringIdx) = sum(data == 10) + 1;
    clear data
    fclose(fileID);
end
totalNumRows = sum(nLines);

data = cell(1,3);
data{1} = zeros(totalNumRows,1,'int32');
data{2} = zeros(totalNumRows,1,'int32');
data{3} = zeros(totalNumRows,1,'double');

fromRow = 1;
for fileStringIdx = 1:length(fileStrings)
    fileID = fopen(fileStrings{fileStringIdx});
    
    % The below results in struct, with:
    % tempdata{1} having meter_ID
    % tampdata{2} having time_index
    % tempdata{3} having kWh in that 0.5-hour step
    tempdata = textscan(fileID,formatSpec,nLines,'Delimiter','\n');
    for colNum = 1:3
        data{colNum}(fromRow:(fromRow+nLines(fileStringIdx)-2)) = ...
            tempdata{colNum};
    end
    clear tempdata;
    fromRow = fromRow + nLines(fileStringIdx);
    fclose(fileID);
end
toc;

for fileStringIdx = 1:length(fileStrings)
    
    fileID = fopen(fileString(fileStringIdx));
    
    %% Ascertain number of lines:
    %# Get file size.
    fseek(fileID, 0, 'eof');
    fileSize = ftell(fileID);
    frewind(fileID);
    %# Read the whole file.
    data = fread(fileID, fileSize, 'uint8');
    %# Count number of line-feeds and increase by one.
    nLines = sum(data == 10) + 1;
    clear data
    
    % Re-set to start of file
    frewind(fileID);
    
    % The below results in struct, with:
    % data{.}{1} having meter_ID
    % data{.}{2} having time_index
    % data{.}{3} having kWh in that 0.5-hour step
    data{fileStringIdx} = ...
        textscan(fileID,formatSpec,nLines,'Delimiter','\n');
end
toc;

% Extract list of unique meter numbers and number of reads for each:
uniqueMeters = unique(data{1});
meterHistoricReads = zeros(length(uniqueMeters), 2);
for i = 1:length(uniqueMeters)
    meterHistoricReads(i, 1) = uniqueMeters(i);
    meterHistoricReads(i, 2) = sum(data{1} == uniqueMeters(i));
end

% Close the file again
fclose(fileID);

% Extract data for the all meters which have 25730 records (the
% most common large number of historic reads); corresponds to over 1 year
longReadLength = 25730;
uniqueMeteresLongRead = meterHistoricReads(meterHistoricReads(:, 2) ==...
    longReadLength, 1);

% Extract the first N
% nMeters = 50;
% uniqueMeteresLongRead = uniqueMeteresLongRead(1:nMeters);

% NB: it is necessary to cast type to double to prevent kWh float being
% cast to integers
demandData = [double(data{1}), double(data{2}), data{3}];
demandData = demandData(ismember(demandData(:, 1), ...
    uniqueMeteresLongRead), :);

% Remove old data file to free up memory
clear data;

% Extract each meter reading into separate page of 3-d matrix, and sort
% into time order
meterReads = zeros(longReadLength, 3,  length(uniqueMeteresLongRead));
for i = 1:length(uniqueMeteresLongRead)
   meterReads(:, :, i) = demandData(demandData(:, 1) == ...
       uniqueMeteresLongRead(i), :);
   meterReads(:, :, i) = sortrows(meterReads(:, :, i), 2);
end

% Plot a series for each meter
figure(1);
plot(squeeze(meterReads(:, 3, :)));
xlabel('Time [daycode-hrcode]');
ylabel('Energy Use by Meter [kWh/time-step]');

% sum together all these meters
sumMeterReads = sum(meterReads(:, 3, :), 3);

% Plot this sum
figure(2);
plot(sumMeterReads);
xlabel('Time [daycode-hrcode]');
ylabel('Average Energy Use [kWh/time-step]');

% Create a time vector, and cast sumMeterReads to a t-series variable:
stepsPerDay = 48;
nDays = ceil(length(sumMeterReads)/stepsPerDay);
t = 0:(1/stepsPerDay):(nDays-(1/stepsPerDay));
t = t(1:length(sumMeterReads));
sumMeterReadsTimeSeries = timeseries(sumMeterReads, t');
sumMeterReadsTimeSeries.TimeInfo.Units = 'days';

% Create a multivariate timeseries object woth individual meter readings:
demandDataTimeSeries = timeseries(squeeze(meterReads(:, 3, :)), t');
demandDataTimeSeries.TimeInfo.Units = 'days';

%% Save demandData variable:
% Filename is so labelled because the above analysis should result in
% 3,639 meters being extracted from the original data set
save('demand_3639.mat', demandData);

toc;