function perf = perfwb(wb,~)

% Regularization performance used to minimize weights and biases
% (e.g. could use manhattan or euclidean parameter vector lengths)

perf = sum(wb.^2);
