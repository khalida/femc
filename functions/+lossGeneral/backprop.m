function dy = backprop(t,y,~,param)
% lossGeneral.backprop

loss = @(y)param.lossGeneral(t, y);

% Using 1-sided gradient here for speed
% May actually reduce over-all speed (more iterations required)
dy = calculateNumericGradients(loss, y, 1);
% dy = calculateNumericGradients(loss, y, 2);

end
