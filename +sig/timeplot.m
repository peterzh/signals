function listeners = timeplot(varargin)
%SIG.PLOT Summary of this function goes here
%   TODO Document
%   TODO Vararg for axes name value args, e.g. LineWidth
%   TODO Deal with logging signals & registries & subscriptable signals
%   TODO Deal with strings, arrays, structures, cell arrays
%sigs, figh, mode, tWin
[present, value, idx] = namedArg(varargin, 'parent');
if present
  figh = value;
  varargin(idx:idx+1) = [];
else
  figh = figure('Name', 'LivePlot', 'NumberTitle', 'off', 'Color', 'w');
end
[present, value, idx] = namedArg(varargin, 'mode');
if present
  mode = value;
  varargin(idx:idx+1) = [];
else
  mode = 0;
end

[present, value, idx] = namedArg(varargin, 'tWin');
if present
  tWin = value;
  varargin(idx:idx+1) = [];
else
  tWin = 5;
end

clf(figh);

sigs = StructRef;

for i = 1:length(varargin)
  s = varargin{i};
  name = genvarname(s.Name);
  switch class(s)
    case {'sig.Registry', 'StructRef'}
      %names = strcat([name '_'], fieldnames(s));
      names = strcat(fieldnames(s));      
      values = struct2cell(s);
      for j = 1:length(names)
        sigs.(names{j}) = values{j};
      end
    case {'sig.Signal', 'sig.node.Signal', ...
        'sig.node.ScanningSignal', 'sig.node.OriginSignal'}
      sigs.(name) = s;
    otherwise
      error('Unrecognized type')
  end
end
names = fieldnames(sigs);
names{1} = 'Time Signal';
n = numel(names);
tstart = [];
lastval = cell(n,1);

cmap = colormap(figh, 'hsv');
skipsInCmap = length(cmap) / n;
cmap = cmap(1:skipsInCmap:end, :);

args = {'linewidth' 2};

axh = zeros(n,1);
x_t = cell(n,1);
fontsz = 9;

if numel(mode) == 1
  mode = repmat(mode, n, 1);
end

signals = struct2cell(sigs);

for i = 1:n
  axh(i) = subtightplot(n,1,i,[0.02,0.2],0.05,0.05,'parent',figh);
  x_t{i} = signals{i}.map(...
    @(x)struct('x',{x},'t',{GetSecs}), '%s(t)');
  curTitle = title(axh(i), names{i}, 'fontsize', 8, 'interpreter', 'none');
%   titlePos = get(curTitle, 'Position');
%   set(curTitle, 'Position', [titlePos(1), titlePos(2)-0.4, titlePos(3)]);
  if i == n    
    xlabel(axh(i), 't (s)', 'fontsize',fontsz);
  else
    set(axh(i),'XTickLabel',[]);
  end
end

set(axh,'NextPlot','add', 'fontsize',fontsz);

for ii = 1:n
  if mode(ii) == 1
    plot(axh(ii), [0 100], [0 0]);
  end
end

for i = 1:n % add listeners to the signals that will update the plots
  listeners(i,1) = onValue(x_t{i}, @(v)new(i,v));
end

%set(axh, 'Xlim', [GetSecs-tWin GetSecs+tWin]);
set(axh, 'Xlim', [0 1]);
set(axh,'ButtonDownFcn',@(s,~)cycleMode(s))

  function new(idx, value)
    value.x = iff(ischar(value.x), true, value.x);
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
        scatter(axh(idx), value.t-tstart, value.x, 'x', 'MarkerEdgeColor', cmap(idx,:), args{:});
        stairs(axh(idx), tt, xx, 'Color', cmap(idx,:), args{:});
      case 1 % plot as a stream of discrete events, no intevening values
        xx = [0 value.x];
        tt = [value.t value.t]-tstart;
        scatter(axh(idx), value.t-tstart, value.x, 'o', 'MarkerEdgeColor', cmap(idx,:), args{:});
        stairs(axh(idx), tt, xx, 'Color', cmap(idx,:), args{:});
      case 2 % plot as a signal, without showing change points, and interpolate
        xx = [lastval{idx}.x value.x];
        tt = [lastval{idx}.t value.t]-tstart;
        line(tt, xx, 'Parent', axh(idx), 'Color', cmap(idx,:), args{:});
    end
    lastval{idx} = value;
    set(axh, 'Xlim', [GetSecs-tstart-tWin GetSecs-tstart+tWin]);
  end

  function cycleMode(src)
    id = src==axh;
    if mode(id) == 2
      mode(id) = 0;
    else
      mode(id) = mode(id) + 1;
    end
  end
end

