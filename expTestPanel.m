function expTestPanel(expdef)
%UNTITLED Summary of this function goes here
%   Input: Handle to experiment definition function

%% Questions/TODO:
% - allow for making global parameters conditional
% - save 'block' file
% - delete 'Wheel Position' slider and improve behavior of unsetting cursor as wheel
% - PTB 'Screen' stuff: vc, vcc? & VBL syncing and DWM compositor issues? & get screen resolution right for PTB 'Screen'
% - add support for multiple screens
%% Panel UI set-up
% initialize global/persistent variables and graphics
addSignalsJava(); % adds necessary Java files (classes)
InitializeMatlabOpenGL
global AGL GL GLU %#ok<NUSED> %used by PTB
persistent defdir lastPars; %#ok<PUSE>
if isempty(lastPars)
  lastPars = containers.Map('KeyType', 'char', 'ValueType', 'any');
end

[parsFig, mainbox, ctrlgrid, applyParsBtn, startExpBtn, reRunExpBtn,... 
  runAnotherExpBtn, trialNumCount, rewardCount, wheelslider] = setExpDefPanel; %local function

%% get experiment definition and its parameters

[mfile, mpath, defdir, expdef, expdefname, parsStruct] = setPars; %local function

%% experiment framework

[parsEditor, vc, listhandle, textureById, layersByName, model,...
      screen, invalid, tmr, isRunning, tLast, renderCount, sn, dt, t, net,... 
      inputs, outputs, vs, audio, evts, globalPars, allCondPars, pars,... 
      hasNext, repeatNum, advanceTrial, setCtrlStr, listeners, cursor,... 
      signalsFig, expStarted] = setExp; %local function

%% main local functions (setExpDefPanel, setPars, setExp)

  function [parsFig, mainbox, ctrlgrid, applyParsBtn, startExpBtn, reRunExpBtn,... 
  runAnotherExpBtn, trialNumCount, rewardCount, wheelslider] = setExpDefPanel
  
    % create panel
    parsFig = figure('Name', 'ExpTestPanel',...
      'NumberTitle', 'off', 'Toolbar', 'none', 'Menubar', 'none',...
      'Position', [800 550 800 580]);
    %'Name', sprintf('%s', expdefname),...
    %mainsplit = uiextras.HBox('Parent', parsWindow);
    %mainbox = uiextras.VBox('Parent', mainsplit);
    mainbox = uiextras.VBox('Parent', parsFig);
    
    % create a grid for containing the buttons created below
    ctrlgrid = uiextras.Grid('Parent', mainbox);
    
    % create "Apply Parameters" button
    applyParsBtn = uicontrol('Parent', ctrlgrid, 'Style', 'pushbutton',...
      'String', 'Apply Parameters', 'Callback', @applyPars);
    
    % create "Start Experiment" button
    startExpBtn = uicontrol('Parent', ctrlgrid, 'Style', 'pushbutton',...
      'String', 'Start Experiment', 'Callback', @startExp);
    
    % create button to play stimuli
    reRunExpBtn = uicontrol('Parent', ctrlgrid, 'Style', 'pushbutton',...
      'String', 'Re-run Exp Def', 'Callback', @reRunExpDef);
    
    % create "Run Another Exp Def" button
    runAnotherExpBtn = uicontrol('Parent', ctrlgrid, 'Style', 'pushbutton',...
      'String', 'Run Another Exp Def', 'Callback', @runXExpDef);
    
    % create a "Trial" text
    uicontrol('Parent', ctrlgrid, 'Style', 'text', 'String', 'Trial');
    % create Trial Number counter text
    trialNumCount = uicontrol('Parent', ctrlgrid, 'Style', 'text', 'String', '0');
    % create a "Reward Delivered" text
    uicontrol('Parent', ctrlgrid, 'Style', 'text', 'String', 'Reward Delivered');
    % create "Reward Delivered counter text
    rewardCount = uicontrol('Parent', ctrlgrid, 'Style', 'text', 'String', '0');
    
    uicontrol('Parent', ctrlgrid, 'Style', 'text', 'String', 'Wheel Position'); % create a "Wheel Position" text
    wheelslider = uicontrol('Parent', ctrlgrid, 'Style', 'slider',...
    'Callback', @wheelSliderChanged, 'Min', -50, 'Max', 50, 'Value', 0);
    
    % emulate wheel input
%     set(parsFig, 'KeyPressFcn', @wheelTurn);
  end

  function [mfile, mpath, defdir, expdef, expdefname, parsStruct] = setPars
    
    % if expdef not specified as input arg, get it
    %    if nargin < 1
    [mfile, mpath] = uigetfile(...
      '*.m', 'Select the experiment definition function');
    if mfile == 0
      return
    end
    defdir = mpath;
    [~, expdefname] = fileparts(mfile);
    expdef = fileFunction(mpath, mfile);
    %    else
    %      expdefname = func2str(expdef);
    %    end
    
    parsStruct = exp.inferParameters(expdef);
    %parsStruct = rmfield(parsStruct, 'defFunction');
    % expRef is posted to expStart signal: "see startExp"
    parsStruct.expRef = dat.constructExpRef('empty', now, 1);
    parsStruct.expDefFunctionFile = expdefname;
  end

  function [parsEditor, vc, listhandle, textureById, layersByName, model,...
      screen, invalid, tmr, isRunning, tLast, renderCount, sn, dt, t, net,... 
      inputs, outputs, vs, audio, evts, globalPars, allCondPars, pars,... 
      hasNext, repeatNum, advanceTrial, setCtrlStr, listeners, cursor,... 
      signalsFig, expStarted] = setExp
    % set up parameter editor in panel
    parsEditor = eui.ParamEditor(exp.Parameters(parsStruct), mainbox);
    
    % touch-up spacing of ctrlgrid
    ctrlgrid.RowSizes = [-1 -1];
    ctrlgrid.Padding = 5;
    ctrlgrid.Spacing = 10;
    mainbox.Sizes = [-1 -4];
    %leftbox.Sizes = [-1 30 25];
    %parslist = addlistener(parsEditor, 'Changed', @appl);
    
    % PTB Screen Args: (open, monitor, color, position=[L,T,R,B], pixelSz)
    % *note: position is different than MATLAB default: [L,B,R,T]
    Screen('CloseAll') % close any other open screens
    gInfo = groot;
    numMonitors = size(gInfo.MonitorPositions, 1);
    if numMonitors > 1
      [vc, rect] = Screen('OpenWindow', 1, 40, [1,40,840,601], 32);
    else
      [vc, rect] = Screen('OpenWindow', 0, 40, [1,40,840,601], 32);
    end
    Screen('FillRect', vc, 255/2);
    Screen('Flip', vc);
    
    set(bui.parentFigure(ctrlgrid), 'DeleteFcn', @cleanup);
    
    %vbox = uiextras.VBox('Parent', ctrlgrid);
    %[vc, vcc] = vis.component(vbox);
    %vc.clearColour([0.5 0.5 0.5 1]);
    
    listhandle = [];
    textureById = containers.Map('KeyType', 'char', 'ValueType', 'uint32');
    layersByName = containers.Map();
    model = vis.init(vc);
    screen = vis.screen([0 0 10], 0, [21.5 16], [0 0 800 600]);        % left screen
    %screens(1) = vis.screen([0 0 9.5], -90, [8 6], [0 0 800 600]);        % left screen
    %screens(2) = vis.screen([0 0 10],  0 , [8 6], [800 0 2*800 600]);    % ahead screen
    %screens(3) = vis.screen([0 0 9.5],  90, [8 6], [2*800  0 3*800 600]); % right screen
    model.screens = screen;
    invalid = false;
    
    tmr = timer('ExecutionMode', 'fixedSpacing', 'Period', 5e-3,...
      'TimerFcn', @process, 'Name', 'MainLoop');
    isRunning = false;
    tLast = [];
    renderCount = 0;
    
    sn = sig.Net;
    dt = sn.origin('dt');
    t = dt.scan(@plus, 0);
  
    net = t.Node.Net;
    % inputs & outputs
    inputs = sig.Registry; % create inputs as logging signals
    
    inputs.wheel = net.origin('wheel');
    inputs.keyboard = net.origin('keyboard');
    outputs = sig.Registry; % create outputs as logging signals
    % video and audio registries
    vs = StructRef; % hold visual signals as a structure (StructRef is overloaded MATLAB 'struct')
    audio = audstream.Registry(); % assign to registry; post samples assigned to it from audio device (without saving)
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
    expdef(t, evts, pars, vs, inputs, outputs, audio); % run expdef with origin signals
    
    setCtrlStr = @(h)@(v)set(h, 'String', toStr(v)); % @h = handle, @v = value
    
    cursor = sn.origin('cursor');
    
    listeners = [
      evts.expStart.into(advanceTrial) % expStart signals advance
      evts.endTrial.into(advanceTrial) % endTrial signals advance
      advanceTrial.map(true).keepWhen(hasNext).into(evts.newTrial) %newTrial if more
      evts.trialNum.onValue(setCtrlStr(trialNumCount))
      cursor.into(inputs.wheel)
      ];
    
    if isfield(outputs, 'reward')  % to-do display all outputs in UI
      listeners = [listeners
        outputs.reward.scan(@plus, 0).onValue(setCtrlStr(rewardCount))];
    end
    
    % plot the signals
    signalsFig = figure('Name', 'LivePlot', 'NumberTitle', 'off');
    
    % use sig.timeplot for live plotting
    listeners = [listeners
      sig.timeplot(t, evts, 'parent', signalsFig, 'mode', 0, 'tWin', 5)];
    
    expStarted = false;
    
  end

%% secondary local functions and callbacks

% emulate wheel input when user clicks mouse scroll button

set(parsFig, 'WindowButtonDownFcn', @wheelTurn);
cursorAsWheel = true;
disp('Mouse cursor as wheel input emulator has been set')
% cursor = sn.origin('cursor');
% listeners = [listeners
%   cursor.into(inputs.wheel)
%   ];

  function wheelTurn(src, event)
    if strcmp(get(src, 'SelectionType'), 'extend')
      cursorAsWheel = not(cursorAsWheel);
      if cursorAsWheel
        % set last position of mouse=0
        disp('Mouse cursor as wheel input emulator has been set')
      else
        % get the last position of the mouse
        disp('Mouse cursor as wheel input emulator unset')
      end
    end
  end

  function process(~,~)
    tnow = GetSecs;
    post(dt, tnow - tLast);
    % use mouse cursor as wheel input if it has been user selected
    if cursorAsWheel
      post(cursor, GetMouse()); % - last position of mouse
    end
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
    if evts.expStop.Node.CurrValue % end experiment
      stop(tmr);
      fprintf(2, '\nExperiment Ended.\n\n');
      
      % below: alternate way to display end of experiment using dialog box
%       hd = dialog('Name','Experiment Ended'); %, 'Position', [300 300 250 150]);
%       endText = uicontrol('Parent', hd, 'Style', 'text', ...
%         'Position',[20 150 200 40], ...
%         'String', 'Your experiment has ended. Close this box to continue.',...
%         'fontsize', 12); 
    end
  end

  function cleanup(~,~)
    % some of these values may not exist during certain times when
    % "cleanup" is called, so catch exceptions when they don't exist
    try
      stop(tmr);
      delete(tmr);
    catch end
    try
      close('LivePlot')
    catch end
    try
      t.end(t.Node.Id, 1);
      dt.end(dt.Node.Id, 1);
      sn.delete();
    catch end
    try
      % delete gl textures
      listhandle = [];
      tex = cell2mat(textureById.values);
      fprintf('Deleting %i textures\n', numel(tex));
      glDeleteTextures(numel(tex), tex);
      textureById.remove(textureById.keys);
    catch end
    try
      Screen('AsyncFlipEnd', vc);
      Screen('BeginOpenGL', vc);
      Screen('EndOpenGL', vc);
    catch end
    Screen('CloseAll');
    trialNumCount.String = '0';
    rewardCount.String = '0';
    startExpBtn.String = 'Start Experiment';
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
      %fn = fields{fi};
      %layerSig = elems.(fn).Node.CurrValue.layers;
      %listhandle = [listhandle; layerSig.onValue(@(v)newLayers(fn, v))];
      %elems.(fn).post(elems.(fn).Node.CurrValue); % ugly hack to refresh
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
    %if ~isempty(l)
      %layersByName.(name) = l;
      %alllayers = struct2cell(layersByName);
      %alllayers = horzcat(alllayers{:});
      %vc.setLayers(struct2cell(alllayers')');
      % load textures
      %layerData = obj.LayersByStim(name);
      %Screen('BeginOpenGL', vc);
      %try
        %vis.loadLayerTextures(alllayers);
      %catch glEx
        %Screen('EndOpenGL', vc);
        %rethrow(glEx);
      %end
      %Screen('EndOpenGL', vc);
      %invalid = true;
    %end
  end

  function applyPars(~,~)
    setElements(vs);
    [~, gpars, cpars] = toConditionServer(parsEditor.Parameters);
    globalPars.post(gpars);
    allCondPars.post(cpars);
    disp('Parameters Applied');
  end

  function startExp(~,~)
    if not(expStarted)
      tLast = GetSecs;
      isRunning = true;
      start(tmr);
      evts.expStart.post(parsStruct.expRef);
      % inputs.wheel.post(get(wheelslider, 'Value'));
      set(startExpBtn, 'String', 'Pause');
      expStarted = true;
    else
      if isRunning
        isRunning = false;
        stop(tmr);
        set(startExpBtn, 'String', 'Play');
      else
        tLast = GetSecs;
        isRunning = true;
        start(tmr);
        set(startExpBtn, 'String', 'Pause');
      end
    end
  end

  function reRunExpDef(~,~)
    mainboxChldrn = get(mainbox, 'Children');
    delete(mainboxChldrn(1)); %delete parameter editor before re-loading
    cleanup;
    [parsEditor, vc, listhandle, textureById, layersByName, model,...
      screen, invalid, tmr, isRunning, tLast, renderCount, sn, dt, t, net,...
      inputs, outputs, vs, audio, evts, globalPars, allCondPars, pars,...
      hasNext, repeatNum, advanceTrial, setCtrlStr, listeners, cursor,...
      signalsFig, expStarted] = setExp;
  end

  function runXExpDef(~,~)
    mainboxChldrn = get(mainbox, 'Children');
    
%     expDefSelect = questdlg('Which Exp Def would you like to run?',...
%       'Select Exp Def', 'Re-run Current Exp Def', 'Select A Different Exp Def',...
%       'Re-run Current Exp Def');
%     
%     switch expDefSelect
%       case 'Re-run Current Exp Def'
%         delete(mainboxChldrn(1)); %delete parameter editor before re-loading
%         cleanup;
%         [parsEditor, vc, listhandle, textureById, layersByName, model,...
%           screen, invalid, tmr, isRunning, tLast, renderCount, sn, dt, t, net,...
%           inputs, outputs, vs, audio, evts, globalPars, allCondPars, pars,...
%           hasNext, repeatNum, advanceTrial, setCtrlStr, listeners, cursor,...
%           signalsFig, expStarted] = setExp;
%         
%       case 'Select A Different Exp Def'
        delete(mainboxChldrn(1)); %delete parameter editor before loading a different
        cleanup;
        [mfile, mpath, defdir, expdef, expdefname, parsStruct] = setPars;
        
        [parsEditor, vc, listhandle, textureById, layersByName, model,...
          screen, invalid, tmr, isRunning, tLast, renderCount, sn, dt, t, net,...
          inputs, outputs, vs, audio, evts, globalPars, allCondPars, pars,...
          hasNext, repeatNum, advanceTrial, setCtrlStr, listeners, cursor,...
          signalsFig, expStarted] = setExp;
  end

 function wheelSliderChanged(src, ~)
   set(src, 'Min', get(src, 'Value') - 50, 'Max', get(src, 'Value') + 50);
   wheelDelta = get(src, 'Value') * 50;
   inputs.wheel.post(wheelDelta);
 end
  

end