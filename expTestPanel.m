function expTestPanel(expdef)
%UNTITLED Summary of this function goes here
%   Input: Handle to experiment definition function

%% Questions:

% - why have defFunction as parameter field?
% - why construct ExpRef parameter (as opposed to any other)?
%     - avoiding redundant cases of this construction?
% - if isempty(defFunction), set it to file name? (like in MC)
% - remove default paths to zserver?

% - new layer values?
% - setElements?
% - vc, vcc?
% - VBL syncing and DWM compositor issues?

%% get experiment definition and its parameters

addSignalsJava(); % adds necessary Java files (classes) to *signals*
InitializeMatlabOpenGL
global AGL GL GLU %#ok<NUSED> %used by PTB 
% persistent variables for convenience when repeatedly running this panel
persistent defdir lastParams; %#ok<PUSE> 

if isempty(lastParams)
  lastParams = containers.Map('KeyType', 'char', 'ValueType', 'any');
end

% if expdef not specified as input arg, get it
if nargin < 1
  [mfile, mpath] = uigetfile(...
    '*.m', 'Select the experiment definition function');
  if mfile == 0
    return
  end
  defdir = mpath;
  [~, expdefname] = fileparts(mfile);
  expdef = fileFunction(mpath, mfile);
else
  expdefname = func2str(expdef);
end

parsStruct = exp.inferParameters(expdef);
%%%parsStruct = rmfield(parsStruct, 'defFunction');
% expRef is posted to expStart signal: "see startExp" (also, what is daily sequence number?)
parsStruct.expRef = dat.constructExpRef('tutorial1', now, 1); 
parsStruct.expDefFunctionFile = expdefname;

%% UI & PTB set-up

parsWindow = figure('Name', sprintf('%s', expdefname),...-
  'NumberTitle', 'off', 'Toolbar', 'none', 'Menubar', 'none',...
  'Position', [800 550 800 580]);
%%%mainsplit = uiextras.HBox('Parent', parsWindow);
%%%mainbox = uiextras.VBox('Parent', mainsplit);
mainbox = uiextras.VBox('Parent', parsWindow);

% to-do: keep aspect ratio of param editor boxes even 
% set up parameter editor in GUI
parsEditor = eui.ParamEditor(exp.Parameters(parsStruct), mainbox); 

% create a grid for containing the buttons created below
ctrlgrid = uiextras.Grid('Parent', mainbox); 

% create "Apply Parameters" button
applyParsBtn = uicontrol('Parent', ctrlgrid, 'Style', 'pushbutton',...
'String', 'Apply Parameters', 'Callback', @applyPars); 

% create button to play stimuli
playStimBtn = uicontrol('Parent', ctrlgrid, 'Style', 'pushbutton',... 
  'String', 'Play Stimuli', 'Callback', @playStim);

% create "Start Experiment" button
startExpBtn = uicontrol('Parent', ctrlgrid, 'Style', 'pushbutton',...
  'String', 'Start Experiment', 'Callback', @startExp); 

% create "Run Another Exp Def" button
runXBtn = uicontrol('Parent', ctrlgrid, 'Style', 'pushbutton',...
  'String', 'Run Another Exp Def', 'Callback', @runXExpDef); 

% create a "Trial" text
uicontrol('Parent', ctrlgrid, 'Style', 'text', 'String', 'Trial'); 
% create Trial Number counter text
trialNumCount = uicontrol('Parent', ctrlgrid, 'Style', 'text', 'String', '0'); 
% create a "Reward Delivered" text
uicontrol('Parent', ctrlgrid, 'Style', 'text', 'String', 'Reward Delivered'); 
% create "Reward Delivered counter text
rewardCount = uicontrol('Parent', ctrlgrid, 'Style', 'text', 'String', '0'); 

%%%uicontrol('Parent', ctrlgrid, 'Style', 'text', 'String', 'Wheel Position'); % create a "Wheel Position" text
%%%wheelslider = uicontrol('Parent', ctrlgrid, 'Style', 'slider', 
  %%%'Callback', @wheelSliderChanged, 'Min', -50, 'Max', 50, 'Value', 0);

%%%wheelslider = uicontrol('Parent', ctrlgrid, 'Style', 'slider',...
%%%  'Min', -50, 'Max', 50, 'Value', 0); % create slider as wheel emulator

% touch-up spacing of ctrlgrid
ctrlgrid.RowSizes = [-1 -1];
ctrlgrid.Padding = 5;
ctrlgrid.Spacing = 10;
mainbox.Sizes = [-4 -1];
%%%leftbox.Sizes = [-1 30 25];
%%%parslist = addlistener(parsEditor, 'Changed', @appl);

% PTB Screen Args: (open, monitor, color, position=[L,T,R,B], pixelSz)
% *note: position is different than MATLAB default: [L,B,R,T]
[vc, rect] = Screen('OpenWindow', 1, 40, [1,40,840,601], 32);
Screen('FillRect', vc, 255/2);
Screen('Flip', vc);

set(bui.parentFigure(ctrlgrid), 'DeleteFcn', @cleanup);

%%%vbox = uiextras.VBox('Parent', ctrlgrid);
%%%[vc, vcc] = vis.component(vbox);
%%%vc.clearColour([0.5 0.5 0.5 1]);

listhandle = [];
textureById = containers.Map('KeyType', 'char', 'ValueType', 'uint32');
layersByName = containers.Map();
model = vis.init(vc);
screen = vis.screen([0 0 10], 0, [21.5 16], [0 0 800 600]);        % left screen
%%%screens(1) = vis.screen([0 0 9.5], -90, [8 6], [0 0 800 600]);        % left screen
%%%screens(2) = vis.screen([0 0 10],  0 , [8 6], [800 0 2*800 600]);    % ahead screen
%%%screens(3) = vis.screen([0 0 9.5],  90, [8 6], [2*800  0 3*800 600]); % right screen
model.screens = screen;
invalid = false;

%% experiment framework

tmr = timer('ExecutionMode', 'fixedSpacing', 'Period', 5e-3,...
  'TimerFcn', @process, 'Name', 'MainLoop'); 
isRunning = false;
tLast = [];
renderCount = 0;
%%%cursorPos = hw.CursorPosition;

sn = sig.Net;
dt = sn.origin('dt');
t = dt.scan(@plus, 0);
%%%cursor = sn.origin('cursor');

net = t.Node.Net;
% inputs & outputs
inputs = sig.Registry; %create inputs as logging signals

inputs.wheel = net.origin('wheel');
inputs.keyboard = net.origin('keyboard');
outputs = sig.Registry; %create outputs as logging signals
% video and audio registries
vs = StructRef; %hold visual signals as a structure (StructRef is ~overloaded MATLAB 'struct'
audio = audstream.Registry(); %assign to registry; post samples assigned to it from audio device (without saving)
% events registry
evts = sig.Registry;
evts.expStart = net.origin('expStart');
evts.expStop = net.origin('expStop');
evts.newTrial = net.origin('newTrial');
evts.trialNum = evts.newTrial.scan(@plus, 0); % track trial number
advanceTrial = net.origin('advanceTrial');
% parameters
globalPars = net.origin('globalPars');
allCondPars = net.origin('condPars');

[pars, hasNext, repeatNum] = exp.trialConditions(...
  globalPars, allCondPars, advanceTrial);
expdef(t, evts, pars, vs, inputs, outputs, audio); %run expdef with origin signals 

setCtrlStr = @(h)@(v)set(h, 'String', toStr(v));
listeners = [
  evts.expStart.into(advanceTrial) %expStart signals advance
  evts.endTrial.into(advanceTrial) %endTrial signals advance
  advanceTrial.map(true).keepWhen(hasNext).into(evts.newTrial) %newTrial if more
  evts.trialNum.onValue(setCtrlStr(trialNumCount))
%%%  cursor.into(inputs.wheel)
  ];

if isfield(outputs, 'reward')  % to-do display all outputs in UI
  listeners = [listeners...
    outputs.reward.scan(@plus, 0).onValue(setCtrlStr(rewardCount))];
end

%% plotting the signals
sigsFig = figure('Name', 'LivePlot', 'NumberTitle', 'off'); 

% use sig.timeplot for live plotting
listeners = [listeners,
  sig.timeplot(t, evts, 'parent', sigsFig, 'mode', 0, 'tWin', 5)];

%% callbacks & nested functions

  function process(~,~)
    tnow = GetSecs;
    %     tic
    post(dt, tnow - tLast);
%%%    post(cursor, GetMouse());
%%%    post(cursor, readAbsolutePosition(cp));
%%%    fprintf('%.0f\n', 1000*toc);
    tLast = tnow;
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
    try
      close('LivePlot')
    catch
    end
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
%%%       fn = fields{fi};
%%%       layerSig = elems.(fn).Node.CurrValue.layers;
%%%       listhandle = [listhandle; layerSig.onValue(@(v)newLayers(fn, v))];
%%%       elems.(fn).post(elems.(fn).Node.CurrValue); % ugly hack to refresh
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

  function applyPars(~,~)
    setElements(vs);
    [~, gpars, cpars] = toConditionServer(parsEditor.Parameters);
    globalPars.post(gpars);
    allCondPars.post(cpars);
    disp('parameters applied');
  end

  function playStim(~,~)
    if isRunning
      isRunning = false;
      stop(tmr);
      set(playStimBtn, 'String', 'Play');
    else
      tLast = GetSecs;
      isRunning = true;
      start(tmr);
      set(playStimBtn, 'String', 'Pause');
    end
  end

  function startExp(~,~)
    applyPars();
    evts.expStart.post(parsStruct.expRef);
%%% inputs.wheel.post(get(wheelslider, 'Value'));
  end

  function runXExpDef(~,~)
    %...
  end

%%%  function wheelSliderChanged(src, ~)
%%%    set(src, 'Min', get(src, 'Value') - 50, 'Max', get(src, 'Value') + 50);
%%%    inputs.wheel.post(get(src, 'Value'));
%%%  end
  

end