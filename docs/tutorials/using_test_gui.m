%% Introduction
% This document demonstrates how to test Signals Experiment Definition
% (expDef) functions in the test GUI.  The GUI opens a PTB window and a
% Parameter Editor for live-updating parameters.  Before opening the test
% GUI, loading the debug settings for PTB will make the window transparent.
% This is particularly useful on small screens(1).
PsychDebugWindowConfiguration

%% Opening your expDef in the GUI
% Upon calling the |eui.SignalsTest| class with no inputs you will be
% prompted to select your function from the file browser.  As with |MC|,
% the default folder location is set by the 'expDefinitions' field in
% dat.paths.
%
% You can also call the function with the function name or function handle.
% The function must be on the MATLAB path.  Let's run one of the example
% expDef functions: the Burgess wheel task(2) implemented in Signals.
PsychDebugWindowConfiguration % Make window transparant and turn of blocking
root = fileparts(which('addRigboxPaths')); % Location of Rigbox root dir
cd(fullfile(root, 'signals', 'docs', 'examples')) % Change to examples folder

e = eui.SignalsTest(@advancedChoiceWorld) % Start GUI and loaded expDef

%% Default settings
% The hardware wheel input is simulated in the experiment GUI by the
% position of the cursor over the stimulus window.  Upon clicking start the
% 'expStart' event updates with the the experiment ref string.  The ref
% string can be changed by editing the Ref property before pressing start:
e.Ref = dat.constructExpRef('subject', now-7, 2);

% Moving the cursor over the window will move the visual stimulus in the
% stimulus window.

%% Testing different hardware
% A hardware structure can be assigned to the Hardware property of the test
% object:
e.Hardware = hw.devices;

%% Live plotting
% The value of the event Signals can be plotted live by checking the
% LivePlot option in the Options popup.  It can also be set by changing the
% LivePlot property:
e.LivePlot = 'on';

%% Experiment panel
% For more info, see <./using_ExpPanel.html Using ExpPanel>.
% TODO Document

%% Notes
% (1) These settings can be cleared by calling the Screen function:
clear Screen
% (2) <https://doi.org/10.1016/j.celrep.2017.08.047 DOI:10.1016/j.celrep.2017.08.047>

%% Etc.
% Author: Miles Wells
%
% v0.0.1

%#ok<*NOPTS,*NASGU,*ASGLU>
