function [ String ] = toString( Variable )
%TOSTRING converts any type to a string.
%   Something like this should already exist, but it's elusive.
if isinteger(Variable)
    String = int2str(Variable);
elseif ischar(Variable)
    String = Variable;
elseif isfloat(Variable)
    String = sprintf('%g', Variable);
elseif iscell(Variable)
    String = toString(Variable{1});
else
    error(['toString does not currently support the ', class(Variable),...
        ' class']);
end
end