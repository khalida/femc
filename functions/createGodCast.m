function [ godCast ] = createGodCast( timeSeries, horizonLength )
%createGodCast: create a perfect foresight horizon forecast for each t-step

% issue warning if timeSeries is not 1-dimensional
if min(size(timeSeries)) ~= 1 || ndims(timeSeries) > 2 %#ok<ISMAT>
    error('timeSeries must be 1-dimensional!');
end

% convert time-series to column vector:
timeSeries = timeSeries(:);

% pre-allocation
godCast = zeros(length(timeSeries), horizonLength);

for ii = 1:horizonLength
    godCast(:, ii) = circshift(timeSeries, -[ii-1, 0]);
end

% Delete wrap-around errors:
nToKeep = length(timeSeries) - horizonLength + 1;
godCast = godCast(1:nToKeep, :);

end
