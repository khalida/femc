function ew = perfw_to_ew(perfw)
%GEN_LOSS.PERFW_TO_EW

if iscell(perfw)
    ew = cell(size(perfw));
    for i=1:numel(ew)
        ew{i} = sqrt(perfw{i});
    end
else
    ew = sqrt(perfw);
end
