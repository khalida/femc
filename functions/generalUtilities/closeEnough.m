function [ isCloseEnough ] = closeEnough( first, second, tol )
%closeEnough: Returns boolean true/false if first, second within tol

if abs(first-second) <= abs(tol) + eps
    isCloseEnough = true;
else
    isCloseEnough = false;
end

end
