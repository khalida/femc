%% Test by confirming performance on a couple of simple examples:

test1 = makeAllLimitedPermutations(4, 0);
expectedResult1 = [1; 2; 3; 4];
pass1 = isequal(test1, expectedResult1);

test2 = makeAllLimitedPermutations(4, 1);
expectedResult2 = [ 1  1  1  2  2;
    2  2  3  1  1;
    3  4  2  3  4;
    4  3  4  4  3 ];
% NB: in result above the permuations of the columns don't matter:
nColumns = size(expectedResult2, 2);
if nColumns ~= size(test2, 2)
    error('makeAllLimitedPermutations test FAILED!');
end
columnPermutations = perms(1:nColumns);
nColumnPermutations = size(columnPermutations, 1);

pass2 = false;
for iColumnPermutation = 1:nColumnPermutations
    if isequal(expectedResult2, test2(:, ...
            columnPermutations(iColumnPermutation, :)))
        pass2 = true;
    end
end

test3 = makeAllLimitedPermutations(4, 2);
expectedResult3 = [ 3 3 3 3 2 2 2 2 1 1 1 1 1 1
    4 2 1 1 3 4 1 1 3 3 2 2 4 4
    1 1 2 4 1 1 4 3 2 4 3 4 2 3
    2 4 4 2 4 3 3 4 4 2 4 3 3 2 ];

% NB: in result above the permuations of the columns don't matter:
nColumns = size(expectedResult3, 2);
if nColumns ~= size(test3, 2)
    error('makeAllLimitedPermutations test FAILED!');
end
columnPermutations = perms(1:nColumns);
nColumnPermutations = size(columnPermutations, 1);

pass3 = false;
for iColumnPermutation = 1:nColumnPermutations
    if isequal(expectedResult3, test3(:, ...
            columnPermutations(iColumnPermutation)))
        pass3 = true;
    end
end

if pass1 && pass2 && pass3 && pass4
    disp('makeAllLimitedPermutations test PASSED!');
else
    error('makeAllLimitedPermutations test FAILED!');
end
