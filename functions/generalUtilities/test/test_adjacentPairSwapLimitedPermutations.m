%% Test using some simple examples for which results are known:
clearvars;

% Not an exhaustive unit test
test1 = adjacentPairSwapLimitedPermutations(4, 0);
expectedResult1 = [1; 2; 3; 4];
pass1 = isequal(test1, expectedResult1);

test2 = adjacentPairSwapLimitedPermutations(4, 1);
expectedResult2 = [ 1  2  1  1  ;
                    2  1  3  2  ;
                    3  3  2  4  ;
                    4  4  4  3  ];
% NB: in result above the permuations of the columns don't matter:
nColumns = size(expectedResult2, 2);
if nColumns ~= size(test2, 2)
    error('test_adjacentPairSwapLimitedPermutations FAILED!');
end

nColumnsFound = 0;
for iColumn = 1:nColumns
    for jColumn = 1:nColumns
        if isequal(expectedResult2(:, iColumn), test2(:, jColumn))
            nColumnsFound = nColumnsFound + 1;
        end
    end
end
pass2 = nColumnsFound == nColumns;


test3 = adjacentPairSwapLimitedPermutations(4, 2);
expectedResult3 = [ 1  2  1  1  2  2  3  1  1 ;
                    2  1  3  2  3  1  1  3  4 ;
                    3  3  2  4  1  4  2  4  2 ;
                    4  4  4  3  4  3  4  2  3 ];

% NB: in result above the permuations of the columns don't matter:
nColumns = size(expectedResult3, 2);
if nColumns ~= size(test3, 2)
    error('test_adjacentPairSwapLimitedPermutations FAILED!');
end

nColumnsFound = 0;
for iColumn = 1:nColumns
    for jColumn = 1:nColumns
        if isequal(expectedResult3(:, iColumn), test3(:, jColumn))
            nColumnsFound = nColumnsFound + 1;
        end
    end
end
pass3 = nColumnsFound == nColumns;

if pass1 && pass2 && pass3
    disp('test_adjacentPairSwapLimitedPermutations PASSED!');
else
    error('test_adjacentPairSwapLimitedPermutations FAILED');
end
