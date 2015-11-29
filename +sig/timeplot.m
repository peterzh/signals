function listeners = timeplot(figh, sigs, mode, tmax)
%SIG.PLOT Summary of this function goes here
%   Detailed explanation goes here

clf(figh);

n = numel(sigs);
tstart = [];
lastval = cell(n,1);
args = {'linewidth' 2};

axh = zeros(n,1);
fontsz = 12;

if numel(mode) == 1
  mode = repmat(mode, n, 1);
end


for i = 1:n
  axh(i) = subplot(n,1,i,'parent',figh);
  x_t(i) = sigs(i).map(...
    @(x)struct('x',{x},'t',{GetSecs}), '%s(t)');
  ylabel(axh(i), sigs(i).Name, 'fontsize',fontsz);
  if i == n    
    xlabel(axh(i), 't (s)', 'fontsize',fontsz);
  end
end

set(axh,'NextPlot','add', 'fontsize',fontsz);

for ii = 1:n
  if mode(ii) == 1
    plot(axh(ii), [0 100], [0 0]);
  end
end

for i = 1:n % add listeners to the signals that will update the plots
  listeners(i) = x_t(i).onValue(@(v)new(i,v));
end

set(axh, 'Xlim', [0-0.1 tmax+0.1]);

  function new(idx, value)
    if isempty(tstart)
      tstart = GetSecs;
    end
    if isempty(lastval{idx})
      lastval{idx} = value;
    end
    
    switch mode(idx)
      case 0 % plot as a signal, but with change points shown
        xx = [lastval{idx}.x value.x];
        tt = [lastval{idx}.t value.t]-tstart;
        scatter(axh(idx), value.t-tstart, value.x, 'x', args{:});
        stairs(axh(idx), tt, xx, args{:});
      case 1 % plot as a stream of discrete events, no intevening values
        xx = [0 value.x];
        tt = [value.t value.t]-tstart;
        scatter(axh(idx), value.t-tstart, value.x, 'o', args{:});
        stairs(axh(idx), tt, xx, args{:});
      case 2 % plot as a signal, without showing change points, and interpolate
        xx = [lastval{idx}.x value.x];
        tt = [lastval{idx}.t value.t]-tstart;
        line(tt, xx, 'Parent', axh(idx), args{:});
    end
    lastval{idx} = value;
  end

end

