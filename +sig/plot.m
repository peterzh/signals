function listener = plot(axh, x, y, varargin)
%SIG.PLOT Summary of this function goes here
%   Detailed explanation goes here

pltsig = x.map2(...
  @(x,y)struct('x',{x},'y',{y}), y, '{x:%s,y:%s}',@(name)sig.Logger(name));

plth = [];
listener = event.listener(pltsig, 'NewValue', @new);

  function new(~,~)
    vals = pltsig.Values;
    xx = [vals.x];
    yy = [vals.y];
    if ~isempty(plth)
      set(plth, 'XData', xx, 'YData', yy);
    else
      plth = plot(axh, xx, yy, varargin{:});
    end
  end

end

