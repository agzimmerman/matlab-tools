function Config = config(SpecifiedPairs, DefaultPairs)
%CONFIG is a general optinal argument configuration tool
%   Config = CONFIG(SpecifiedPairs, DefaultPairs)
%
%       SpecifiedPairs must be a cell array of Name Value pairs. Every
%       other member, beginning with the first, must be a char array. The
%       other members can be any type. These are typically obtained as a
%       varargin from the parent program.
%
%       DefaultPairs has the same requirements as SpecifiedPairs, but Names
%       found in SpecifiedPairs will take priority over names found in
%       DefaultPairs. These are typically a constant in the parent program.
%
%       Each specified name must match a default name.
%
%       Config is a struct where Config.Name = Value
%
%   TODO: Type checking, other validation
for i = 1:2:(length(SpecifiedPairs) - 1)
    Config.(SpecifiedPairs{i}) = SpecifiedPairs{i+1};
end

SpecifiedNames = SpecifiedPairs(1:2:(end-1));
DefaultNames = DefaultPairs(1:2:(end-1));

assert(all(ismember(SpecifiedNames, DefaultNames)));

for i = 1:2:(length(DefaultPairs) - 1)
    DefaultName = DefaultPairs{i};
    if ismember(DefaultName, SpecifiedNames)
        continue
    end
    Config.(DefaultName) = DefaultPairs{i+1};
end

end