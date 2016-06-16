function [ emd_column ] = emd_hat_gd_metric_mex_vec_par( P, Q, pars )
%EMD_HAT_MEX_VEC_PAR Vectorised version of emd_hat_mex, which is also
% parametrised

% INPUTS:
% P: matrix of actual values [nHorzn x nObs]
% Q: matrix of forecast values [nHorzn x nObs]
% pars: vector of loss_emd parameters:
        % a: cost of adding a unit of energy
        % b: fraction of 'a' charged for removing a unit of energy
        % c: cost for moving unit of energy to later time-step (to eariler cost=1)
        % d: threshold for ground distance matrix.
        
% OUTPUTS:
% emd_column: row-vector giving emd for each column in {P, Q} [1 x nObs]

a = pars(1); b = pars(2); c = pars(3); d = pars(4);

if (a*b) < d
    error(['a*b must be >= d to ensure charging for energy' ...
    'added/removed is correct. a:' num2str(a) ', b:' num2str(b) ...
    ', c:' num2str(c) ', d:' num2str(d) '.']);
end

nHorzn = size(P, 1);
if size(Q, 1) ~= nHorzn
    error('P and Q must have same number of positions in horizon')
end

% Create ground-distance matrix
threshold = d;
D = ones(nHorzn,nHorzn).*threshold;
for i = 1:nHorzn
    for j = max([1 i-threshold+1]):min([nHorzn (i+threshold/c-1)])
        if i<=j
            D(i,j) = abs(i-j); 
        else
            D(i,j) = abs(i-j)*c;
        end
    end
end

nObs = size(P, 2);

if nObs ~= size(Q,2)
    error('P and Q must have same number of observations (columns)');
end

emd_column = zeros(1, nObs);
for ii = 1:nObs
   thisP = P(:, ii);
   thisQ = Q(:, ii);
   minVal = -min([thisP; thisQ]);
   
   if sum(thisP) > sum(thisQ)   % Actual more than forecast
       emd_column(1, ii) = emd_hat_gd_metric_mex(thisP+minVal,...
           thisQ+minVal, D, a);
   else                         % Forecast more than actual
       emd_column(1, ii) = emd_hat_gd_metric_mex(thisP+minVal,...
           thisQ+minVal, D, a*b);
   end
end

end
