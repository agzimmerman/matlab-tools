function Table = my_read_table(FilePath, HeaderLineCount, ColumnCount)
% Unfortunately the built-in readtable can't treat multiple delimiters as
% one.
%
% This function is not very generalized. You'll have to edit it. This is
% essentially just documenting how to go about doing this in MATLAB.

    String = fileread(FilePath);
    
    VariableNameCellsCell = textscan(String, '%s', ColumnCount);
    VariableNameCells = VariableNameCellsCell{1};
    
    DoublesCell = textscan(String,...
        '%f',...
        'HeaderLines', HeaderLineCount,...
        'Delimiter', ' ',...
        'MultipleDelimsAsOne', true,...
        'EndOfLine', '\n');
    Doubles = DoublesCell{1};
    Columns = reshape(Doubles, ColumnCount, length(Doubles)/ColumnCount)';
    
    Table = array2table(Columns);
    Table.Properties.VariableNames = VariableNameCells;
    
end

    