function Values = where(Mask, TrueValues, FalseValues)
%%WHERE assigns vector values based on a logical mask.
%   Based on the behavior of numpy/where.
Values = NaN(size(Mask));
Values(~Mask) = FalseValues;
Values(Mask) = TrueValues(Mask);
end