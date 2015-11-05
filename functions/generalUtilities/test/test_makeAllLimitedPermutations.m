%% Test by confirming performance on a couple of simple examples:
% test the permutation radius limited version of SJT permmutation at
% the same time.

test1 = makeAllLimitedPermutations(4, 0);
test1_SJT = steinhausJohnsonTrotterLimited(4,0);
expectedResult1 = [1; 2; 3; 4];
pass1 = isequal(test1, expectedResult1);
pass1_SJT = isequal(test1, expectedResult1);

test2 = makeAllLimitedPermutations(4, 1);
test2_SJT = steinhausJohnsonTrotterLimited(4,1);
expectedResult2 = [ 1  1  1  2  2;
    2  2  3  1  1;
    3  4  2  3  4;
    4  3  4  4  3 ];
% NB: in result above the permuations of the columns don't matter:
nColumns = size(expectedResult2, 2);
if nColumns ~= size(test2, 2)
    error('makeAllLimitedPermutations test FAILED!');
end
if nColumns ~= size(test2_SJT, 2)
    error('steinhausJohnsonTrotterLimited test FAILED!');
end

nColumnsFound = 0;
nColumnsFound_SJT = 0;
for iColumn = 1:nColumns
    for jColumn = 1:nColumns
        if isequal(expectedResult2(:, iColumn), test2(:, jColumn))
            nColumnsFound = nColumnsFound + 1;
        end
        if isequal(expectedResult2(:, iColumn), test2_SJT(:, jColumn))
            nColumnsFound_SJT = nColumnsFound_SJT + 1;
        end
    end
end
pass2 = nColumnsFound == nColumns;
pass2_SJT = nColumnsFound_SJT == nColumns;

test3 = makeAllLimitedPermutations(4, 2);
test3_SJT = makeAllLimitedPermutations(4, 2);
expectedResult3 = [ 3 3 3 3 2 2 2 2 1 1 1 1 1 1
    4 2 1 1 3 4 1 1 3 3 2 2 4 4
    1 1 2 4 1 1 4 3 2 4 3 4 2 3
    2 4 4 2 4 3 3 4 4 2 4 3 3 2 ];

% NB: in result above the permuations of the columns don't matter:
nColumns = size(expectedResult3, 2);
if nColumns ~= size(test3, 2)
    error('makeAllLimitedPermutations test FAILED!');
end
if nColumns ~= size(test3_SJT, 2)
    error('makeAllLimitedPermutations test FAILED!');
end

nColumnsFound = 0;
nColumnsFound_SJT = 0;
for iColumn = 1:nColumns
    for jColumn = 1:nColumns
        if isequal(expectedResult3(:, iColumn), test3(:, jColumn))
            nColumnsFound = nColumnsFound + 1;
        end
        if isequal(expectedResult3(:, iColumn), test3_SJT(:, jColumn))
            nColumnsFound_SJT = nColumnsFound_SJT + 1;
        end
    end
end
pass3 = nColumnsFound == nColumns;
pass3_SJT = nColumnsFound_SJT == nColumns;


if pass1 && pass2 && pass3
    disp('makeAllLimitedPermutations test PASSED!');
else
    error('makeAllLimitedPermutations test FAILED!');
end

if pass1_SJT && pass2_SJT && pass3_SJT
    disp('steinhausJohnsonTrotterLimited test PASSED!');
else
    error('steinhausJohnsonTrotterLimited test FAILED!');
end
