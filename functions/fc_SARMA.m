% file: fc_SARMA.m
% auth: Khalid Abdulla
% date: 10/12/2014
% brief: Produce k-step forecast

function [ fc ] = fc_SARMA(parsIn, demand, supp)
%FC_SARMA k-Step forecast using SARMA(3,0)x(1,0)

% demand:   historic demand up to and *including* fcast origin
% parsIn:   the parameters of SARMA model (including k and s)

k = parsIn.k;    	% number of steps into future to fcast
pars = parsIn.pars; % model coefficients

% fc = zeros(k, 1);

% TODO: Assumes order (0,3)x(1,0) would be better to generalise
%       (could also perhaps tidy up)

theta = pars(1:3);
phi = pars(4);

% Produce each forecast step into future in turn (results rely on prev.
% steps)

% M-file version of code
% fc = fc_SARMA_mex(demand, theta, phi, k);

% Mex version of code (faster)
fc = fc_SARMA_mex(demand((end-k+1):end), theta, phi, k);

if ~supp
   disp('fcast = '); disp(fc); 
end

end