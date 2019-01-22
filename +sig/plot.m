function h = plot(varargin)
%SIG.PLOT Summary of this function goes here
%   Detailed explanation goes here

if ishandle(varargin{1})
  axh = varargin{1};
  x = varargin{2};
  y = varargin{3};
  varargin(1:3) = [];
else
  figure('Name', 'X-Y Plot', 'NumberTitle', 'off', 'Color', 'w');
  axh = subplot(1,1,1);
  x = varargin{1};
  y = varargin{2};
  varargin(1:2) = [];
end
mode = 2;
set(axh,'NextPlot','add');
sc = y.scan(@new, [], 'pars', x);
h = TidyHandle(@()deleteNode(sc.Node.NetId, sc.Node.Id));

% xx = x.log();
% yy = y.log();
% pltsig = xx.map2(yy, @new);
% listener = pltsig.onValue(@new);

  function prev = new(prev,y,x)
    xx = iff(isempty(prev), x, @()[prev(1) x]);
    yy = iff(isempty(prev), y, @()[prev(2) y]);
    switch mode
      case 0 % plot as a signal, but with change points shown
        scatter(axh, xx, yy, 'x', varargin{:});
        stairs(axh, xx, yy, varargin{:});
      case 1 % plot as a stream of discrete events, no intevening values
        scatter(axh, xx, yy, 'o', varargin{:});
        stairs(axh, xx, yy, varargin{:});
      case 2 % plot as a signal, without showing change points, and interpolate
        line(xx, yy, 'Parent', axh, varargin{:});
    end
    prev = [x;y];
  end

end

