function [ emd_column ] = emd_hat_gd_metric_mex_vec( P, Q )
% EMD_HAT_MEX_VEC Vectorised version of emd_hat_mex

% emd_hat_mex(P,Q,D,extra_mass_penalty,FType), can only handle P, Q,
%           as column vectors. This function interprets P,Q as a [M x N]
%           matrix where M is the number of 'points' on each EMD comparison
%           and N is the number of EMD distances to return (as a [1 x N
%           column)

% also resolves issue that emd_hat_mex has out with negative values in P, Q

% deafult TODO: Consider playing with this!
extra_mass_penalty = -1;    

N = size(P, 1);
if size(Q, 1) ~= N
    error('P and Q must have same number of positions')
end

% Create ground-distance matrix
threshold = max(10, floor(N/10));              % TODO: need to play with this!
D = ones(N,N).*threshold;
for i = 1:N
    for j = max([1 i-threshold+1]):min([N i+threshold-1])
        D(i,j) = abs(i-j); 
    end
end

numEMDs = size(P, 2);

if numEMDs ~= size(Q,2)
    error('P and Q must have same number of columns');
end

emd_column = zeros(1, numEMDs);
for ii = 1:numEMDs
   thisP = P(:, ii);
   thisQ = Q(:, ii);
   minVal = -min([thisP; thisQ]);
   emd_column(1, ii) = emd_hat_gd_metric_mex(thisP+minVal,thisQ+minVal, ... 
       D,extra_mass_penalty);
end

end
