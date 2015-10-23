%% Test by computing gradients for which an analytic solution exists:

functionHandle = @(x) x(1,:).^2 + x(2,:).^3 + x(3, :).^4;
x0 = rand(3, 100) + 1;
analyticalGradients = [2*x0(1,:); 3*x0(2,:).^2; 4*x0(3,:).^3];

oneSidedGradients = calculateNumericGradients( functionHandle,...
    x0, 1);
oneSidedPercentageError = (analyticalGradients - oneSidedGradients) ./ ...
    analyticalGradients;

twoSidedGradients = calculateNumericGradients( functionHandle,...
    x0, 2);
twoSidedPercentageError = (analyticalGradients - twoSidedGradients) ./ ...
    analyticalGradients;

oneSidedErrorOk = max(oneSidedPercentageError(:)) < 1e-5;
twoSidedErrorOk = max(twoSidedPercentageError(:)) < 1e-6;

if oneSidedErrorOk && twoSidedErrorOk
    disp('calculateNumericGradients test PASSED!');
else
    error('calculateNumericGradients test FAILED!');
end
