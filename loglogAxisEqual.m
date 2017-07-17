function loglogAxisEqual(AxisHandles, XLimits, YLimits)
%%LOGLOGAXISEQUAL replaces the "axis equal" command for loglog figures.
if (nargin < 2) || isempty(XLimits)
    XLimits = get(AxisHandles,'XLim');
end
if (nargin < 3) || isempty(YLimits)
    YLimits = get(AxisHandles,'YLim');
end
LogScale = diff(YLimits)/diff(XLimits);
PowerScale = diff(log10(YLimits))/diff(log10(XLimits));
set(AxisHandles, 'Xlim', XLimits, 'YLim', YLimits,...
    'DataAspectRatio', [1 LogScale/PowerScale 1]);
end