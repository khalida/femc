function [ trainControlOut ] = setDefaultValues( trainControlIn, ...
    fieldValuePairs)

% setDefaultValues: Set default values of structure, and issue warnings as
% required

nFields = length(fieldValuePairs)/2;
if ~isWholeNumber(nFields)
    error('Need to have an even number of fields + values');
end

trainControlOut = trainControlIn;

for iField = 1:nFields
    thisFieldName = fieldValuePairs{2*iField-1};
    thisFieldValue = fieldValuePairs{2*iField};
    
    if ~isfield(trainControlOut, thisFieldName)
        trainControlOut.(thisFieldName) = thisFieldValue;
        warning off backtrace;
        warning(['Using default ' inputname(1) '.' thisFieldName ':']);
        warning on backtrace;
        disp(thisFieldValue);
    end
end;

end
