%% Signals Test Script
% Every signal is part of a network, managed through a 'sig.Net' object.
% The network object holds all the ids of every signals node

% Every signal has an underlying node, a sig.node.Node object that contains
% a number of important properties:
% Net: a handle to the parent network (sig.Net)
% Inputs: an array of input nodes
% Id: an integer ID used by the low level C code
% NetId: an integer ID for the parent network, used by the low level C code
% CurrValue: the current value that the node holds

%% Origin signals
% An origin signal is a special sub-class of the sig.node.Signal object
% that allows one to directly update its value using the post method. It
% takes two inputs: the parent network and optionally, a string identifier.
%
% These origin signals are the input nodes to the reactive network, while
% all other signals are dependent on one another.  Origin signals can be a
% value of any type, as demonstrated below.

net = sig.Net; % Create a new signals network
originSignal = net.origin('input'); % Create an origin signal
originSignal.Node.CurrValue % The current value is empty

post(originSignal, 21) % Post a new value to originSignal
originSignal.Node.CurrValue % The current value is now 21

post(originSignal, 'hello') % Post a new value to originSignal
originSignal.Node.CurrValue % The current value is now 'hello'

%% Relationships between signals
net = sig.Net; % Create a new signals network
originSignal = net.origin('input'); % Create an origin signal
sig2 = originSignal.scan(@plus, 1);
sig2.Node.CurrValue
sig2.Node.WorkingValue
post(originSignal, 4)

%% Demonstration on sig.Signal/output() method
% The output method is a useful function for understanding the relationship
% between signals.  It simply displays a signal's output each time it takes
% a value.  The output method returns an object of the class TidyHandle,
% which is like a normal handle, however when it's lifecyle ends it will
% delete itself.  What this means is that when the handle is no longer
% referenced anywhere (i.e. stored as a variable), the callback will no
% longer function.
net = sig.Net; % Create a new signals network
clc % Clear previous output for clarity

simpleSignal = net.origin('simpleSignal');
h = output(simpleSignal.not);
class(h)

simpleSignal.post(false)
simpleSignal.post(true)


%% Timing in signals
% Most experiments require things to occur at specific times.  This can be
% achieved by having a timing signal that has a clock value posted to it
% periodically.  In the following example we will create a 'time' signal
% that takes the value returned by 'now' every second.  We achieve this
% with a fixed-rate timer.

net = sig.Net; % Create a new signals network
clc % Clear previous output for clarity
time = net.origin('t'); % Create a time signal
% NB: The onValue method is very similar to the output method, but allows
% you to define any callback function to be called each time the signal
% takes a value (so long as the handle is still around).  Here we are using
% it to display the farmatted value of our 't' signal 
handle = time.onValue(@(t)fprintf('%.3f sec\n', t*10e4)); %#ok<*NASGU>

t0 = now; % Record current time
% Create a timer that posts the time since t0 to the 'time' signal at a
% given rate given by 'frequency'.
frequency = 1; % Update the timer every second
tmr = timer('TimerFcn', @(~,~)post(time, now-t0),...
    'ExecutionMode', 'fixedrate', 'Period', 1/frequency);
start(tmr) % Start the timer
disp('Timer started')
% ...Because of the output method, we are seeing the value of the time
% signal displayed every second
pause(3)

%%% Now let's increase the frequency to 10 ms...
stop(tmr) % Stop the timer
frequency = 1e-2; % Frequency now 10x higher
disp('Let''s increase the timer frequency to 10 times per second...')
set(tmr, 'Period', frequency)
pause(1) % Ready... steady... go!
start(tmr)
pause(3) % ...

%%% When we clear the handle, the value is no longer displayed
disp('Clearing the output TidyHandle')
clear handle
pause(1) % ...The values the 'time' signal are no longer displayed

%%% Due to the timer, the value of 'time' continues to update
fprintf('%.3f sec\n', time.Node.CurrValue*10e4)
pause(1)% ...
fprintf('%.3f sec\n', time.Node.CurrValue*10e4)
pause(1)

%%% When the timer is stopped, the value of 'time' is no longer updated
disp('Stopping timer');
stop(tmr)
pause(1)% ...
fprintf('%.3f sec\n', time.Node.CurrValue*10e4)
pause(1)% ...
fprintf('%.3f sec\n', time.Node.CurrValue*10e4)
pause(1)% ...
% Let's clear the variables
delete(tmr); clear tmr frequency t0 time

%% Timing 2 - Scheduling
% The net object contains an attribute called Schedule which 

net = sig.Net; % Create network
frequency = 10e-2; 
tmr = timer('TimerFcn', @(~,~)net.runSchedule,...
    'ExecutionMode', 'fixedrate', 'Period', frequency);
start(tmr) % Run schedule every 10 ms
s = net.origin('input'); % Input signal
delayedSig = s.delay(5); % New signal delayed by 5 sec
h = output(delayedSig); % Let's output its value
h(2) = delayedSig.onValue(@(~)toc); tic
delayedPost(s, pi, 5) % Post to input signal also delayed by 5 sec
disp('Delayed post of pi to input signal (5 seconds)')
% After creating a delayed post, an entry was added to the schedule
disp('Contents of Schedule: '); disp(net.Schedule) 
fprintf('Node id %s corresponds to ''%s'' signal\n\n', num2str(s.Node.Id), s.Node.Name)
% ...
disp('... 5 seconds later...'); pause(5.1)
% ...
% ... a second entry was added to the schedule, this time for 'delayedSig'.
% This was added to the schedule as soon as the value of pi was posted to
% our 'input' signal.
disp('Contents of Schedule: '); disp(net.Schedule) 
fprintf('Node id %s corresponds to ''%s'' signal\n\n',...
    num2str(net.Schedule.nodeid), delayedSig.Node.Name)
% ...
disp('... another 5 seconds later...'); pause(5.1)
% ...
% 3.14
stop(tmr); delete(tmr); clear tmr s frequency h delayedSig

%% Demonstration of sig.Signal/log() method
% Sometimes you want the values of a signal to be logged and timestamped.
% The log method returns a signal that carries a structure with the fields
% 'time' and 'value'.  Log takes two inputs: the signal to be logged and
% an optional clock function to use for the timestamps.  The default clock
% function is GetSecs, a PsychToolbox MEX function that returns the most
% reliable system time available.

net = sig.Net; % Create our network
simpleSignal = net.origin('simpleSignal'); % Create a simple signal to log
loggingSignal = simpleSignal.log(@now); % Log that signal using MATLAB's now function
loggingSignal.onValue(@(a)disp(toStr(a))); % Each time our loggingSignal takes a new value, let's display it

simpleSignal.post(3)
pause(1); fprintf('\n\n')

simpleSignal.post(8)
pause(1); fprintf('\n\n')

simpleSignal.post(false)
pause(1); fprintf('\n\n')

simpleSignal.post('foo')

%% Logging signals in a registry
% In order to simplify things, one can create a registry which will hold
% the logs of all signals added to it.  When the experiment is over, the
% registry can return all the logged values in the timestampes optionally
% offset to another clock.  This can be useful for returning values in
% seconds since the start of the experiment
net = sig.Net; % Create our network
t0 = now; % Let's use this as our example reference time
events = sig.Registry(@now); % Create our registy
simpleSignal = net.origin('simpleSignal'); % Create a simple signal to log
events.signalA = simpleSignal^2; % Log a new signal that takes the second power of the input signal
events.signalB = simpleSignal.lag(2); % Log another signal that takes the last but one value of the input signal
simpleSignal.post(3) % Post some values to the input signal
simpleSignal.post(3)
simpleSignal.post(8)

s = logs(events, t0); % Return our logged signals as a structure
disp(s)

%% Demonstration of working values
% Working values of signals are important for proper signal propagation in
% the C code, as you suspected. Basically each time a new signal value is
% posted (i.e. starting from an 'origin' signal), any dependent signals
% need to be updated to take account of the change. This kind of updating
% is implemented by propagating the changes through the nodes -- where each
% signal is a node, and connections between them are direct dependencies.
% Where the interactions between dependent signals get complicated, this
% can mean a signal/node's value can potentially change more than once
% during a full propagation, but will eventually settle to its final
% correct value. Thus we maintain this 'working value' during the process,
% until the propagation is complete. Then all those signals who got a new
% (working) value, will have their current value updated to the new working
% value.

net = sig.Net; % Create our network
origin = net.origin('input');
a = origin.lag(3);
b = a*origin^2;
%   a = src + 1
%   b = a + src
%   b = identity(b) %

% addlistener(b.Node, 'WorkingValue', 'PostSet', @(src,~)disp(src.WorkingValue))

origin.post(1) % Post some values to the input signal
origin.post(2)
origin.post(3)


%% Demonstration of subscriptable signals
% net = sig.Net;
% A = net.origin('A');
% B = net.origin('B');
% C = net.origin('C');
% structSig = net.origin('structSig');
% post(structSig, struct(...
%   'A', A.scan(@(a,b)nansum([a b]), nan), ...
%   'B', C.scan(@(a,b)nansum([a b]), nan), ...
%   'C', B.scan(@(a,b)nansum([a b]), nan)));
% structSig = structSig.subscriptable;
% post(A, 5)
% sigA = structSig.A;
% 
% % The below is equivilent
% structSig = net.subscriptableOrigin('structSig');
% structSig.CacheSubscripts = true;
% post(structSig, struct(...
%   'A', A.scan(@(a,b)nansum([a b]), nan), ...
%   'B', C.scan(@(a,b)nansum([a b]), nan), ...
%   'C', B.scan(@(a,b)nansum([a b]), nan)));
% post(A, 5)
% sigA = structSig.A
% 
% %% 
% net = sig.Net;
% structSig = net.subscriptableOrigin('structSig');
% structSig.CacheSubscripts = true; % Essential
% structSig.C = net.origin('C');
% structSig.C; % Essential
% structSig.C = 5;
% structSig.C.Node.CurrValue