function h = plot(varargin)
%SIG.PLOT Summary of this function goes here
%   Detailed explanation goes here

if ishandle(varargin{1})
  axh = varargin{1};
  x = varargin{2};
  y = varargin{3};
  varargin(1:3) = [];
else
  figure;
  axh = subplot(1,1,1);
  x = varargin{1};
  y = varargin{2};
  varargin(1:2) = [];
end
% xx = x.log();
% yy = y.log();
yy = y.scan(@new, [], 'pars', x);
h = TidyHandle(@()delete(yy));
% pltsig = xx.map2(yy, @new);
% listener = pltsig.onValue(@new);

  function data = new(acc,y,x)
    data = [acc [x;y]];
    plot(axh, data(1,:), data(2,:), varargin{:});
  end

end

