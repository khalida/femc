function [ permutations ] = steinhausJohnsonTrotterLimited( n, delta )
% steinhausJohnsonTrotter: Produce permutations using SJT algorithm:
%                           subject to a maximum permutation radius  

partialList = {1};

for ii = 2:n
    nRows = length(partialList);
    newRowIdx = 1;
    newPartialList = cell(ii*nRows, 1);
    
    for iRow = 1:nRows
        firstInsertAfter = length(partialList{1});
        if mod(iRow, 2) == 0
            insertAfterRange = max(0, firstInsertAfter-delta):...
                1:firstInsertAfter;
        else
            insertAfterRange = firstInsertAfter:-1:...
                max(0, firstInsertAfter-delta);
        end
        
        for insertAfter = insertAfterRange
            nNumbers = length(partialList{iRow});
            [~, idxs] = ismember(partialList{iRow}, 1:nNumbers);
            idxShifts = abs(idxs - (1:nNumbers));
            if((insertAfter+1) > nNumbers || ...
                    max(abs(idxShifts((insertAfter+1):end)))<delta)
                before = partialList{iRow}(1:insertAfter);
                after = partialList{iRow}((insertAfter+1):end);
                newPartialList{newRowIdx, 1} = [before, ii, after];
                newRowIdx = newRowIdx + 1;
            end
        end
    end
    
    partialList = newPartialList;
end

permutations = cell2mat(partialList);

% Remove any which have indexes further permuted than allowed:


end
