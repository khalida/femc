function dy = backprop(t,y,~,param)
%GEN_LOSS.BACKPROP

loss = @(y)param.gen_loss(t, y);

% TODO: I'm just using 1-sided gradient here to speed things up!
% May actually reduce over-all speed (more iterations required)
dy = calcNumGrads(loss, y, 1);
% dy = calcNumGrads(loss, y, 2);
