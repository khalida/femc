%% Test with a couple of simple examples
clearvars;

pass1 = closeEnough(1.0, 1.1, 0.1);
pass2 = closeEnough(1.0, 0.9, 0.1);
pass3 = ~closeEnough(1.0, 0.8, 0.1);
pass4 = ~closeEnough(1.0, 1.2, 0.1);

if pass1 && pass2 && pass3 && pass4
    disp('test_closeEnough PASSED!');
else
    error('test_closeEnough FAILED');
end
