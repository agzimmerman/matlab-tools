function [ Table ] = combineToTable( varargin )
%COMBINE returns a table of all combinations of the inputs.
%
%   This is similar to combvec, but it accepts heterogeneous inputs and
%   returns a table.
Levels = cellfun(@numel, varargin);
Design = fullfact(Levels);
%% There has to be a better way to do the rest of this, but this works!
Columns = cell(1, length(Levels));
for i = 1:length(Levels)
    Columns{i} = varargin{i}(Design(:,i));
    if size(Columns{i}, 1) == 1 % Ensure that this is a column vector.
        Columns{i} = Columns{i}';
    end
end
Names = cell(1, length(Levels));
for i = 1:length(Levels)
    Names{i} = inputname(i);
    if isempty(Names{i})
        Names{i} = ['Var', int2str(i)];
    end
end
Table = table(Columns{1}, 'VariableNames', Names(1));
for i = 2:length(Levels);
    Table = [Table, table(Columns{i}, 'VariableNames', Names(i))]; %#ok<AGROW>
end
end