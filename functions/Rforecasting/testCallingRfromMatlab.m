data = sum(rand(100), 1);
csvwrite('data.csv', data(:)); % write as a column
system('R CMD BATCH calc.R outputForDebugging.txt');
testResults = csvread('testResults.csv');
testResultsStruct = struct('W_statistic', testResults(1), 'p_value', ...
    testResults(2));
