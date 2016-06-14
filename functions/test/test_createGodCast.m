%% Test by trying a few random vectors, and confirming result
clearvars;
testLength = 10;

%% 1) Test with a horizon length of 1:
horizonLength = 1;
timeSeries = rand(testLength, 1);
godCast = createGodCast(timeSeries, horizonLength);

% For horizon length of one we expect godCast to just be input vector,
% as each row is the 1-interval horizon god-cast
if ~isequal(godCast, timeSeries)
    disp('godCast:'); disp(godCast);
    disp('timeSreies:'); disp(timeSeries);
    error('test_createGodCast TEST 1 FAILED');
else
    disp('test_createGodCast TEST 1 PASSED!');
end

%% 2) Test with a horizon length equal to t-series length
horizonLength = testLength;
godCast = createGodCast(timeSeries, horizonLength);

% We expect this just to transpose the original time series, as only a
% single godCast can be made (the original time series)
if ~isequal(godCast, timeSeries')
    disp('godCast:'); disp(godCast);
    disp('timeSreies:'); disp(timeSeries);
    error('test_createGodCast TEST 2 FAILED');
else
    disp('test_createGodCast TEST 2 PASSED!');
end

%% 3) Test with a horizon length of 2
horizonLength = 2;
godCast = createGodCast(timeSeries, horizonLength);

% We expect this to be a matrix with horizonLength-1 rows, and 2 columns
% each each row having a sequence of 2 of the time-series values:
expectedCast = zeros(testLength-1, 2);
for idx = 1:(testLength-1)
    expectedCast(idx, :) = timeSeries(idx:(idx+1));
end

if ~isequal(godCast, expectedCast)
    disp('godCast:'); disp(godCast);
    disp('timeSreies:'); disp(timeSeries);
    error('test_createGodCast TEST 3 FAILED');
else
    disp('test_createGodCast TEST 3 PASSED!');
end
    