%% Do some simple numerical tests to check expected functionality
clearvars;

areWholeNumbers = [0 1 -10 -14 15 2300 1e6 -2.3e4 -0];
notWholeNumbers = [0.01 -0.9 2.4 2.3435e2 -2.345e2];

positivesCorrect = isWholeNumber(areWholeNumbers);
negativesCorrect = true;
for idx = 1:length(notWholeNumbers)
    negativesCorrect = and(negativesCorrect, ...
        ~isWholeNumber(notWholeNumbers));
end

if positivesCorrect && negativesCorrect
    disp('test_isWholeNumber test PASSED!');
else
    error('test_isWholeNumber test FAILED');
end
