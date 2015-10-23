%% Do some simple numerical tests to check expected functionality

areWholeNumbers = [0 1 -10 -14 15 2300 1e6 -2.3e4 -0];
notWholeNumbers = [0.01 -0.9 2.4 2.3435e2 -2.345e2];

positivesCorrect = isWholeNumber(areWholeNumbers);
negativesCorrect = true;
for idx = 1:length(notWholeNumbers)
    negativesCorrect = and(negativesCorrect, ...
        ~isWholeNumber(notWholeNumbers));
end

if positivesCorrect && negativesCorrect
    disp('isWholeNumber test PASSED!');
else
    error('isWholeNumber test FAILED!');
end
