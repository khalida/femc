function dperf = forwardprop(dy,t,y,~,param)
%GEN_LOSS.FORWARDPROP

loss = @(y)param.gen_loss(t, y);

% TODO: computing 1-sided gradient to speed things up - might actually
% increase overall time (more iters required).
dperf = bsxfun(@times, dy, calcNumGrads(loss, y, 1));
% dperf = bsxfun(@times, dy, calcNumGrads(loss, y, 2));
