function residentialIDs = getResidentialMeterIDs()
% Import the allocation of all meter IDS, and return list of residential
% meter IDs

%% Import the data
[~, ~, raw] = xlsread('SME and Residential allocations.xlsx','Sheet1');
raw = raw(2:end,1:2);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Matrix, meter IDs in column 1, type in column 2
SMEandResidentialallocations = reshape([raw{:}],size(raw));

%% Select meter IDs of residential type (type 1):
residentialIDs = SMEandResidentialallocations(...
    SMEandResidentialallocations(:, 2)==1, 1);

end