function axh = plot(varargin)
%SIG.PLOT Plot two input signals against each other
%   sig.plot(x, y)
%
%   Inputs: x - Signal to be plotted on the x axis
%           y - Signal to be plotted on the y axis
%
%   Outputs: axh - Axes handle
%
%   See also SIG.TIMEPLOT
% TODO Document inline
% TODO Deal with empty input names

if ishandle(varargin{1})
  axh = varargin{1};
  cla(axh);
  x = varargin{2};
  y = varargin{3};
  varargin(1:3) = [];
  titleStr = [inputname(2) ' vs ' inputname(3)];
else
  figure('Name', 'X-Y Plot', 'NumberTitle', 'off', 'Color', 'w');
  titleStr = [inputname(1) ' vs ' inputname(2)];
  axh = subplot(1,1,1);
  x = varargin{1};
  y = varargin{2};
  varargin(1:2) = [];
end
title(axh, titleStr);
xlabel(axh, x.Name); ylabel(axh, y.Name);
if ~any(strcmp(varargin, 'LineWidth'))
  varargin = [varargin {'LineWidth', 2}];
end

xx = [x.lag(1) x];
yy = [y.lag(1) y];
sc = xx.map2(yy, @vertcat);
h = sc.onValue(@new);

set(axh,'NextPlot','add','DeleteFcn', @(~,~)delete(h));
% set(bui.parentFigure(axh), 'DeleteFcn', @(~,~)delete(h));

  function new(xy)
    xx = xy(1,:);
    yy = xy(2,:);
    plot(axh, xx, yy, varargin{:})
  end

end

