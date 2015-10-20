function perfs = apply(t,y,~,param)
%GEN_LOSS.APPLY

loss = @(y)param.gen_loss(t, y);
lossCol = loss(y);
perfs = repmat(lossCol, [size(y, 1), 1]);