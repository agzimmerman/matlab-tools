function plotTable(Table, XName, YName, varargin)
%%PLOTTABLE plots one-dimensional slices of a n-dimensional table.
%
% Required inputs:
%   'Table'
%       Table to be sliced and plotted. [table]
%   'XName'
%       Name of independent variable for figure x-axis. [char array]
%   'YName'
%       Name of dependent variable for figure y-axis. [char array]
%
% Enough optional inputs must be specified such that Table is sliced into
% unique one-dimensional tables for plotting, unless the option 
% 'YMinMeanMax' is set to true, in which case the remaining Y values will 
% be reduced to their statistical min, mean, and max at each X within a 
% slice.
%
% Optional inputs:
%   'LineColorSliceNames'
%       Map these independent variable names to line colors.
%       [char array] or [cell array of char arrays] Default: empty
%   'LineTypeSliceNames'
%       Map these independent variable names to line types.
%       [char array] or [cell array of char arrays] Default: empty
%   'FigureSliceNames'
%       Independent variable names whose uniques combinations map to 
%       individual figures.
%       [char array] or [cell array of char arrays] Default: empty
%   'SaveFiguresAs'
%       Option to save figures in specified format, e.g. 'fig' or 'png'.
%       Multiple formats may be in a cell array, e.g. {'fig', 'png'}.
%       [char array] or [cell array of char arrays] Default: empty
%   'PlotFunction'
%       plotting function handle
%       [function handle] Default: plot
%   'ManualLimits'
%       axes limits (xmin, xmax, ymin, ymax)
%       [1x4 double] Default: empty
%   'SetXTicks'
%       If true, then set the XTicks equal to the unique points in X.
%       [bool] Default: false
%   'YMinMeanMax'
%       Option to plot min(Y), mean(Y), and max(Y) instead of Y.
%       Cannot be used in combination with LineTypeSliceNames.
%       [bool] Default: false
%   'EqualAxis'
%       Set axis equal for each figure.
%       [bool] Default: false
%   'LegendLocation'
%       Legend location for legend() function's 'Location' parameter.
%       [char array] Default: 'Best'
%
%   'LineStyle'
%       Specify a constant line type, with the same notation as PLOT
%       [char array] Default: '-'
%
% The following Properties of Table may be used for annotating the figures.
%   Table.Properties.VariableUnits
%       Labels will include the units. If units are empty then they wil
%       default to ''.
%   Table.Properties.VariableDescriptions
%       If not empty, then labels will use the descriptions rather
%       than the variable names.
%
% Example 1. Plot 1D slices of a 2D table.
%
%   Table = array2table(combvec(rand(1, 2), rand(1, 3))');
%   Table.Properties.VariableNames = {'x', 'y'};
%   Table.f = Table.x.*Table.y;
%   plotTable(Table, 'x', 'f', 'LineSliceNames', 'y')
% 
% Example 2. Annotate a table and plot.
%
%   Table = array2table(combvec(rand(1, 2), rand(1, 3))');
%   Table.Properties.VariableNames = {'x', 'y'};
%   Table.f = Table.x.*Table.y;
%   Table.Properties.VariableDescriptions = {'X Coordinate', 'Y Coordinate', 'Function Value'};
%   Table.Properties.VariableUnits = {'m', 'm', 'm^2'};
%   plotTable(Table, 'x', 'f', 'LineSliceNames', 'y')
%
% Example 3. Plot 2D slices of a 4D table.
%
%   Table = array2table(combvec(rand(1, 2), rand(1, 3), rand(1, 2))');
%   Table.Properties.VariableNames = {'x', 'y', 'z'};
%   Table.f = Table.x.*Table.y.*Table.z;
%   plotTable(Table, 'x', 'f', 'LineSliceNames', 'y',...
%       'FigureSliceNames', 'z')
%
% Example 4. Plot 1D slices of a 2D heterogenous table.
%
%   Table = combineToTable(rand(1, 2), {'a', 'b', 'c'});
%   Table.Properties.VariableNames = {'x', 'foo'};
%   Table.f = Table.x + cellfun(@double, Table.foo)/100.;
%   plotTable(Table, 'x', 'f', 'LineSliceNames', 'foo')
%
% See also TABLE, PLOT

%% Check for required inputs.
if ~exist('XName', 'var')
    error('Specify XName as the second argument.')
end
if ~exist('YName', 'var')
    error('Specify YName as the third argument.')
end
%% Configure options.
DefaultPairs = {
    'LineColorSliceNames', {},...
    'LineTypeSliceNames', {},...
    'FigureSliceNames', {},...
    'SaveFiguresAs', {},...
    'PlotFunction', @plot,...
    'ManualLimits', [],...
    'SetXTicks', false,...
    'YMinMeanMax', false,...
    'EqualAxis', false,...
    'LegendLocation', 'Best',...
    'LineStyle', '-'};
Config = config(varargin, DefaultPairs);
%% Validate some inputs. 
% Force some inputs to be cells.
Names = {'LineColorSliceNames', 'LineTypeSliceNames',...
    'FigureSliceNames', 'SaveFiguresAs'};
for iname = 1:length(Names)
    if ischar(Config.(Names{iname}))
        Config.(Names{iname}) = {Config.(Names{iname})};
    end
end
% Table must have variable units.
if isempty(Table.Properties.VariableUnits)
    VariableUnits = cell(1, width(Table));
    [VariableUnits{1:end}] = deal('');
    Table.Properties.VariableUnits = VariableUnits;
end
%
if ~isempty(Config.LineTypeSliceNames) && Config.YMinMeanMax
    error('LineTypeSliceNames cannot be used with YMinMeanMax enabled.') 
end
%%
Config.LineSliceNames = [Config.LineColorSliceNames,...
    Config.LineTypeSliceNames];
%% Make line color and type tables.
ColorTable = unique(Table(:,Config.LineColorSliceNames));
ColorCount = height(ColorTable);
Color = hsv(ColorCount);
Color = Color(end:-1:1,:); % Re-rder colors from cold to hot.
ColorTable = [ColorTable, table(Color)];
%
TypeTable = unique(Table(:,Config.LineTypeSliceNames));
TypeCount = height(TypeTable);
TypePool = {'-o', '--x', '-.s', '..d'};
if TypeCount > length(TypePool)
    error('Edit the script to extend the TypePool.')
end
TypeTable.Type = cell(height(TypeTable), 1);
for i = 1:height(TypeTable)
    TypeTable.Type(i) = TypePool(i);
end
%% Make a figure for each figure slice.
FigureSliceValues = unique(Table(:,Config.FigureSliceNames));
FigureCount = height(FigureSliceValues);
for ifig = 1:FigureCount
    FigureSliceValue = FigureSliceValues(ifig,:);
    FigureSlice = Table(ismember(Table(:,Config.FigureSliceNames),...
        FigureSliceValue),:);
    Figure = figure();
    if isequal(Config.PlotFunction, @loglog)
        set(gca, 'XScale', 'log', 'YScale', 'log')
    elseif isequal(Config.PlotFunction, @semilogx)
        set(gca, 'XScale', 'log')
    elseif isequal(Config.PlotFunction, @semilogy)
        set(gca, 'YScale', 'log')
    end
    if Config.SetXTicks
        set(gca, 'xtick', table2array(unique(FigureSlice(:,XName))));
    end
    hold on
    %% Plot a line for each line slice (color and type).
    LineSliceValues = unique(FigureSlice(:,...
        [Config.LineColorSliceNames, Config.LineTypeSliceNames]));
    LineCount = height(LineSliceValues);
    if Config.YMinMeanMax
        LegendCount = LineCount + 2; % Add statistics to legend.
    else
        LegendCount = LineCount;
    end
    LegendStrings = cell(1, LegendCount);
    LinesToLabel = NaN(1, LegendCount);
    for iline = 1:LineCount
        LineSliceValue = LineSliceValues(iline,:);
        LineSlice = FigureSlice(ismember(...
            FigureSlice(:,Config.LineSliceNames), LineSliceValue),:);
        Color = ColorTable(ismember(ColorTable(:,Config.LineColorSliceNames),...
            LineSliceValue(:,Config.LineColorSliceNames)),:).Color;
        Type = TypeTable(ismember(TypeTable(:,Config.LineTypeSliceNames),...
            LineSliceValue(:,Config.LineTypeSliceNames)),:).Type{1};
        if ~Config.YMinMeanMax %% Plot Y vs. X.
            LinesToLabel(iline) = Config.PlotFunction(table2array(...
                LineSlice(:,XName)), table2array(LineSlice(:,YName)),...
                Type, 'Color', Color, 'LineStyle', Config.LineStyle);
        else %% Plot min(Y), mean(Y), and max(Y) each vs X.
            % Todo: Separate the statistics part of this code, perhaps by
            % making new tables with reduced statistics and recursively
            % calling plotTable on these instead.
            XValues = table2array(unique(LineSlice(:,XName)));
            XCount = length(XValues);
            YMin = NaN(XCount, 1);
            YMean = NaN(XCount, 1);
            YMax = NaN(XCount, 1);
            for ix = 1:XCount
                XValue = XValues(ix);
                XSlice = LineSlice(table2array(LineSlice(:,XName)) ==...
                    XValue,:);
                YData = table2array(XSlice(:,YName));
                YMin(ix) = min(YData);
                YMean(ix) = mean(YData);
                YMax(ix) = max(YData);
            end
            Config.PlotFunction(XValues, YMin, 'LineStyle', '--',...
                'Color', Color, 'LineWidth', 1);
            LinesToLabel(iline) = Config.PlotFunction(XValues, YMean,...
                'LineStyle', '-', 'Marker', 'o', 'Color', Color);
            Config.PlotFunction(XValues, YMax, 'LineStyle', '--',...
                'Color', Color, 'LineWidth', 1);
            if iline == LineCount
                LinesToLabel(end-1) = Config.PlotFunction(NaN(1,1),...
                    NaN(1,1), '-k', 'LineWidth', 2);
                LinesToLabel(end) = Config.PlotFunction(NaN(1,1),...
                    NaN(1,1), '--k', 'LineWidth', 1);
                LegendStrings{end-1} = 'Mean';
                LegendStrings{end} = 'Min/Max';
            end
        end
        %% Make line label for legend.
        for ils = 1:length(Config.LineSliceNames)
            if ils > 1
                LegendStrings{iline} = [LegendStrings{iline}, ', '];
            end
            Name = Config.LineSliceNames{ils};
            Name = strrep(Name, '_', '\_');
            Val = LineSliceValue(1,ils);
            LegendStrings{iline} = [LegendStrings{iline}, Name, ' = ',...
                toString(Val.(1)), ' ', LineSliceValue.Properties.VariableUnits{1}];
        end
    end
    %% Annotate the figure.
    grid on
    TitleString = '';
    for it = 1:length(Config.FigureSliceNames)
        if it > 1
           TitleString = [TitleString, ', '];  %#ok<AGROW>
        end
        TitleString = [TitleString, Config.FigureSliceNames{it}, ' = ',...
            toString(table2array(FigureSliceValue(1,it)))]; %#ok<AGROW>
    end
    title(TitleString);
    string = [XName, ' [', Table(1,XName).Properties.VariableUnits{1},']'];
    string = strrep(string, '_', '\_');
    xlabel(string);
    string = [YName, ' [', Table(1,YName).Properties.VariableUnits{1},']'];
    string = strrep(string, '_', '\_');
    ylabel(string);
    if ~isempty(Config.ManualLimits)
        xlim([Config.ManualLimits(1), Config.ManualLimits(2)])
        ylim([Config.ManualLimits(3), Config.ManualLimits(4)])
    end
    if Config.EqualAxis
        if isequal(Config.PlotFunction, @loglog) 
            loglogAxisEqual(gca)
        else
            axis equal
        end
    end
    if ~isempty(Config.LineSliceNames)
        legend(LinesToLabel, LegendStrings, 'Location',...
            Config.LegendLocation);
    end
    %% Save the figure.
    if ~isempty(Config.SaveFiguresAs)
        FileName = [YName, 'vs', XName];
        for ifs = 1:length(Config.FigureSliceNames)
            FileName = [FileName, '_', Config.FigureSliceNames{ifs},...
                toString(table2array(FigureSliceValue(1,ifs)))]; %#ok<AGROW>
        end
        for isave = 1:length(Config.SaveFiguresAs)
            saveas(Figure, FileName, Config.SaveFiguresAs{isave});
        end
    end
end
end