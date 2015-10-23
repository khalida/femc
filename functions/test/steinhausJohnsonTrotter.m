function [ permutations ] = steinhausJohnsonTrotter( n )
% steinhausJohnsonTrotter Produce permutations using SJT algorithm:

partialList = {1};

for ii = 2:n
    partialList = partialList(ceil((1:size(partialList,1)*ii)/ii),:);
    nRows = length(partialList);
    insertAfter = length(partialList{1});
    direction = -1;
    for iRow = 1:nRows
           partialList{iRow} = [partialList{iRow}(1:insertAfter), ...
               ii, partialList{iRow}((insertAfter+1):end)];
           insertAfter = insertAfter + direction;
           if(insertAfter == 0 && direction == -1)
               direction = 0;
               
           elseif(insertAfter == 0 && direction == 0)
               direction = 1;
               
           elseif(insertAfter == length(partialList{end}) &&...
                   direction == 1)
               direction = 0;
               
           elseif(insertAfter == length(partialList{end}) &&...
                   direction == 0)
               direction = -1;
           end
    end
end

permutations = cell2mat(partialList);

end
