function dperf = forwardprop(dy,t,y,~,param)
% lossGeneral.forwardprop

loss = @(y)param.lossGeneral(t, y);

% Computing 1-sided gradient for speed - might actually
% increase overall time (more itersations required).
dperf = bsxfun(@times, dy, calculateNumericGradients(loss, y, 1));
% dperf = bsxfun(@times, dy, calculateNumericGradients(loss, y, 2));

end
