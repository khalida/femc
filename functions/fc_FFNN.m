% file: fc_FFNN_MATLAB.m
% auth: Khalid Abdulla
% date: 5/01/2015
% brief: given a neural network and some new inputs for a fcast origin,
%       create a new forecast

function [ fc ] = fc_FFNN( net, demand, supp )

%TODO: I've had to hard-code this here to allow for handling the time-step
delays = 48;

% Check if multiple models exist (i.e. 1 per time-step)
numModels = length(net);
if numModels == 0
    error('Empty object passed as FFNN parameter');
    
elseif numModels == 1
    if net.inputs{1}.size > delays
        x = demand((end - delays):end, :);
    else
        x = demand((end - delays + 1):end, :);
    end
    if ~strcmp(net.performFcn, 'mse')
        if(~supp)
            fc = net(x, nn7);
        else
            % Supress cmd line output
            evalc('fc = net(x, nn7);');
        end
    else
        if(~supp)
            fc = net(x);
        else
            % Supress cmd line output
            evalc('fc = net(x);');
        end
    end
    
else
    
    thisStep = demand(end) + 1;
    selectedNet = net{thisStep};
    x = demand((end - delays):(end-1), 1);
    if ~strcmp(net.performFcn, 'mse')
        if(~supp)
            fc = selectedNet(x, nn7);
        else
            % Supress cmd line output
            evalc('fc = selectedNet(x, nn7);');
        end
    else
        if(~supp)
            fc = selectedNet(x);
        else
            % Supress cmd line output
            evalc('fc = selectedNet(x);');
        end
    end
end

end
