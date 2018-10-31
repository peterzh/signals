function [t, setgraphic] = playgroundPTB(title, parent)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%equivalent to exp.SignalsExp
global AGL GL GLU
InitializeMatlabOpenGL
if nargin < 1
  title = 'Signals playground';
end

if nargin < 2
  parent = figure('Name', title, 'NumberTitle', 'off',...
    'Toolbar', 'none', 'Menubar', 'none');
end

set(bui.parentFigure(parent), 'DeleteFcn', @cleanup);

tmr = timer('ExecutionMode', 'fixedSpacing', 'Period', 5e-3,...
  'TimerFcn', @process, 'Name', 'MainLoop');

vbox = uiextras.VBox('Parent', parent);

%[vc, vcc] = vis.component(vbox);
% vc.clearColour([0.5 0.5 0.5 1]);
vc = Screen('OpenWindow', 1, 0, [50,50,850,650], 32);
Screen('FillRect', vc, 255/2);
Screen('Flip', vc);

btnbox = uiextras.HBox('Parent', vbox);
vbox.Sizes = 30;
btnh = uicontrol('Parent', btnbox, 'Style', 'pushbutton',...
  'String', 'Play', 'Callback', @(~,~)startstop());

sn = sig.Net;
dt = sn.origin('dt');
t = dt.scan(@plus, 0);

tlast = [];
listhandle = [];
textureById = containers.Map('KeyType', 'char', 'ValueType', 'uint32');
layersByName = containers.Map();
model = vis.init(vc);
screen = vis.screen([0 0 10], 0, [21.5 16], [0 0 800 600]);        % left screen
% screens(1) = vis.screen([0 0 9.5], -90, [8 6], [0 0 800 600]);        % left screen
% screens(2) = vis.screen([0 0 10],  0 , [8 6], [800 0 2*800 600]);    % ahead screen
% screens(3) = vis.screen([0 0 9.5],  90, [8 6], [2*800  0 3*800 600]); % right screen
model.screens = screen;

invalid = false;

setgraphic = @setElements;

running = false;
% while running
%   pause(10e-3);
% end

renderCount = 0;

  function startstop()
    if running
      running = false;
      stop(tmr);
      set(btnh, 'String', 'Play');
      stop(timerfind('Tag','figUpdate'))
    else
      tlast = GetSecs;
      running = true;
      start(tmr);
      set(btnh, 'String', 'Pause');
      start(timerfind('Tag','figUpdate'))
    end
  end

  function process(~,~)
    tnow = GetSecs;
%     tic
    post(dt, tnow - tlast);
%     fprintf('%.0f\n', 1000*toc);
    tlast = tnow;
    runSchedule(sn);
    if invalid
      layerValues = cell2mat(layersByName.values());
      Screen('BeginOpenGL', vc);
      vis.draw(vc, model, layerValues, textureById);
      Screen('EndOpenGL', vc);
      Screen('Flip', vc, 0);
      renderCount = renderCount + 1;
      invalid = false;
    end
  end

  function cleanup(~,~)
    stop(tmr);
    delete(tmr);
    close('LivePlot')
    t.end(t.Node.Id, 1)
    dt.end(dt.Node.Id, 1)
    % delete gl textures
    listhandle = [];
    tex = cell2mat(textureById.values);
    fprintf('Deleting %i textures\n', numel(tex));
    Screen('AsyncFlipEnd', vc);
    Screen('BeginOpenGL', vc);
    glDeleteTextures(numel(tex), tex);
    textureById.remove(textureById.keys);
    Screen('EndOpenGL', vc);
    Screen('CloseAll');
    sn.delete();
  end

  function setElements(elems)
    rfgrid = vis.grid(t);
    elems.rfgrid = rfgrid;
    listhandle = [];
    fields = fieldnames(elems);
    for fi = 1:numel(fields)
      layersSig = elems.(fields{fi}).Node.CurrValue.layers;
      listhandle = [listhandle
        layersSig.onValue(fun.partial(@newLayerValues, fields{fi}))];
      newLayerValues(fields{fi}, layersSig.Node.CurrValue);
%       fn = fields{fi};
%       layerSig = elems.(fn).Node.CurrValue.layers;
%       listhandle = [listhandle; layerSig.onValue(@(v)newLayers(fn, v))];
% %       elems.(fn).post(elems.(fn).Node.CurrValue); % ugly hack to refresh
    end
    rfgrid.show = true;
  end

  function newLayerValues(name, l)
      if isKey(layersByName, name)
        prev = layersByName(name);
        prevshow = any([prev.show]);
      else
        prevshow = false;
      end
      layersByName(name) = l;

      if any([l.show]) || prevshow
        invalid = true;
      end
%     if ~isempty(l)
%       layersByName.(name) = l;
%       alllayers = struct2cell(layersByName);
%       alllayers = horzcat(alllayers{:});
% %       vc.setLayers(struct2cell(alllayers')');
% %       %% load textures
% %       layerData = obj.LayersByStim(name);
%       Screen('BeginOpenGL', vc);
%       try
%         vis.loadLayerTextures(alllayers);
%       catch glEx
%         Screen('EndOpenGL', vc);
%         rethrow(glEx);
%       end
%       Screen('EndOpenGL', vc);
%       invalid = true;
%     end
  end

end

