function [ output ] = isWholeNumber( numberToTest )
%ISWHOLENUMBER Check if a number is a whole number or not

output = isequal(fix(numberToTest), numberToTest);

end

