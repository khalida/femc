function fc = fc_SARMA_mex(demand, theta, phi, k) %#codegen

% Assert input types
assert(all(size(demand) == [k 1]));

fc = zeros(size(demand), 'like', demand);

for this_k = 1:k;
    if(this_k<=1)
        fc(this_k) =  theta(1)*demand(end + this_k - 1) + theta(2)*demand(end + this_k - 2) + ...
            theta(3)*demand(end + this_k - 3) + phi*demand(end + this_k - k);
        
    elseif(this_k<=2)
        fc(this_k) =  theta(1)*fc(this_k - 1) + theta(2)*demand(end + this_k - 2) + ...
            theta(3)*demand(end + this_k - 3) + phi*demand(end + this_k - k);
        
    elseif(this_k<=3)
        fc(this_k) =  theta(1)*fc(this_k - 1) + theta(2)*fc(this_k - 2) + ...
            theta(3)*demand(end + this_k - 3) + phi*demand(end + this_k - k);
        
    elseif(this_k<=k)
        fc(this_k) =  theta(1)*fc(this_k - 1) + theta(2)*fc(this_k - 2) + ...
            theta(3)*fc(this_k - 3) + phi*demand(end + this_k - k);
        
    else
        fc(this_k) =  theta(1)*fc(this_k - 1) + theta(2)*fc(this_k - 2) + ...
            theta(3)*fc(this_k - 3) + phi*fc(this_k - k);
    end
end

end
