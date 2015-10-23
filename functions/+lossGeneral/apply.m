function perfermances = apply(t,y,~,param)
% lossGeneral.apply

loss = @(y)param.lossGeneral(t, y);
lossColumn = loss(y);
perfermances = repmat(lossColumn, [size(y, 1), 1]);

end