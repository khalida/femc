% file: importISSDA_data_all.m
% auth: Khalid Abdulla
% date: 14/03/2015
% brief: Import data of interest from ISSDA data set
%            requires care as text files >400MB.
% ver: Extended to import all data and extract only residential customers
clear all; close all; clc;
tic;
%% Data settings
fileStrings = ...
    {'..\..\..\..\..\18_DataSets\ISSDA\data\CER_both\CER Electricity Revised March 2012\File1.txt', ...
    '..\..\..\..\..\18_DataSets\ISSDA\data\CER_both\CER Electricity Revised March 2012\File2.txt', ...
    '..\..\..\..\..\18_DataSets\ISSDA\data\CER_both\CER Electricity Revised March 2012\File3.txt', ...
    '..\..\..\..\..\18_DataSets\ISSDA\data\CER_both\CER Electricity Revised March 2012\File4.txt', ...
    '..\..\..\..\..\18_DataSets\ISSDA\data\CER_both\CER Electricity Revised March 2012\File5.txt', ...
    '..\..\..\..\..\18_DataSets\ISSDA\data\CER_both\CER Electricity Revised March 2012\File6.txt'};

formatSpec = '%d %d %f';

% Get all row lengths
numLines = zeros(length(fileStrings), 1);
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
    numLines(fileStringIdx) = sum(data == 10) + 1;
    clear data
    fclose(fileID);
end
totalNumRows = sum(numLines);

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
    tempdata = textscan(fileID,formatSpec,numLines,'Delimiter','\n');
    for colNum = 1:3
        data{colNum}(fromRow:(fromRow+numLines(fileStringIdx)-2)) = ...
            tempdata{colNum};
    end
    clear tempdata;
    fromRow = fromRow + numLines(fileStringIdx);
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
    numLines = sum(data == 10) + 1;
    clear data
    
    % Re-set to start of file
    frewind(fileID);
    
    % The below results in struct, with:
    % data{.}{1} having meter_ID
    % data{.}{2} having time_index
    % data{.}{3} having kWh in that 0.5-hour step
    data{fileStringIdx} = textscan(fileID,formatSpec,numLines,'Delimiter','\n');
end
toc;

% Extract list of unique meter numbers and number of reads for each:
unique_meters = unique(data{1});
meter_hist = zeros(length(unique_meters), 2);
for i = 1:length(unique_meters)
    meter_hist(i, 1) = unique_meters(i);
    meter_hist(i, 2) = sum(data{1} == unique_meters(i));
end

% Close the file again
fclose(fileID);

% Extract data for the all meters which have 25730 records (seems to
% be most common large number in meter_hist); corresponds to over 1 year
longReadLen = 25730;
unique_meteres_long_read = meter_hist(meter_hist(:, 2) == longReadLen, 1);

% Extract the first N
% numMeters = 50;
% unique_meteres_long_read = unique_meteres_long_read(1:numMeters);

% NB: it is necessary to cast type to double to prevent kWh float being
% cast to integers
allData = [double(data{1}), double(data{2}), data{3}];
allData = allData(ismember(allData(:, 1), unique_meteres_long_read), :);

% Remove old data file to free up memory
clear data;

% Extract each meter reading into separate page of 3-d matrix, and sort
% into time order
meterReads = zeros(longReadLen, 3,  length(unique_meteres_long_read));
for i = 1:length(unique_meteres_long_read)
   meterReads(:, :, i) = allData(allData(:, 1) ==  unique_meteres_long_read(i), :);
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
steps_per_day = 48;
num_days = ceil(length(sumMeterReads)/steps_per_day);
t = 0:(1/steps_per_day):(num_days-(1/steps_per_day));
t = t(1:length(sumMeterReads));
demand710_sum = timeseries(sumMeterReads, t');
demand710_sum.TimeInfo.Units = 'days';

% Create a multivariate timeseries object woth individual meter readings:
demand710_each = timeseries(squeeze(meterReads(:, 3, :)), t');
demand710_each.TimeInfo.Units = 'days';

toc;