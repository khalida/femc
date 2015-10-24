function [ permutations ] = adjacentPairSwapLimitedPermutations( n, ...
    nSwaps )
% adjacentPairSwapLimitedPermutations: Produce all permutations that can
%                           be reached with at most nSwaps adjacent pair
%                           swaps

originalIndexes = 1:n;

partialList = {originalIndexes};

for iSwap = 1:nSwaps
    for iArray = 1:length(partialList)
        existingArray = partialList{iArray};
        if (~isempty(1:(n-1)))
            
            for arrayElement = 1:(n-1)
                newTrialArray = existingArray;
                newTrialArray(arrayElement + (0:1)) = ...
                    newTrialArray(arrayElement + (1:-1:0));
                
                
                isNew = true;
                for k = 1:numel(partialList)
                    if isequal(partialList{k}, newTrialArray)
                        isNew = false;
                        continue;
                    end
                end
                if isNew
                    partialList{numel(partialList)+1, 1} = newTrialArray;
                end
            end
        end
    end
end

permutations = cell2mat(partialList)';

end
