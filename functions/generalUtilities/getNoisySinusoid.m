function [data, periodLength] = getNoisySinusoid()

nPeriods = 100;
periodLength = 10;
noiseMultiplier = 0.5;
sampleInterval = (2*pi)/periodLength;
sampleTimes = (0:sampleInterval:(2*pi*nPeriods))';
data = sin(sampleTimes) + randn(size(sampleTimes)).*noiseMultiplier;

end