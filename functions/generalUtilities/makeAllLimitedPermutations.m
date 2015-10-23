function [ limitedPermutations ] = makeAllLimitedPermutations(horizon, delta)
%makeAllLimitedPermutations: Return all limited radius permutations

% INPUTS:
% horizon:          length of horizon to produce permutations over
% nPermutationsMax: maximum No. of permutations to allow
% delta:            limited radius to consider for permutations

% OUTPUTS:
% allPermutations:  [horizon x nPermutations] matrix of index permutations

nPermutationsMax = 10000;      % Maximum number of ltd radius permutations

if (factorial(delta) > nPermutationsMax)
    error('Too many permutations, reduce delta');
end

originalIndexes = 1:horizon;
allPermutations = perms(originalIndexes);
nRows = size(allPermutations, 1);
maxIdxChanges = zeros(nRows, 1);

for iRow = 1:nRows
    [~, idx] = ismember(allPermutations(iRow, :), originalIndexes);
    maxIdxChanges(iRow, 1) = max(abs(idx - originalIndexes));
end

% Select those permutations where all indexes move at most delta
% also, transpose to get desired output format [horizon x nPermutations]
limitedPermutations = allPermutations(maxIdxChanges <= delta, :)';

end