%% Signals Test Script - Introduction
% The purpose of this script if to introduce Signals, how to wire a network
% and a few of the important functional methods associated.  Later, the
% structure of a Signals experiment will be introduced.

%% 
% Every signal is part of a network, managed through the 'sig.Net' object.
% The network object holds all the ids of every signals node

% Every signal has an underlying node; a sig.node.Node object that contains
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

% Although the value is stored in the Node's CurrValue field, it is not
% intended that you use this field directly.  Doing so will most likely
% lead to unitended behaviour.

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
h = output(simpleSignal);
class(h)

simpleSignal.post(false)
simpleSignal.post(true)

%% Relationships between signals
% Once you have one or more inputs to the network you can start to build a
% reactive network.  Most of MATLAB's elementary operators work with
% Signals objects in the way you would expect, as demonstrated below.

net = sig.Net; % Create a new signals network
x = net.origin('x'); % Create an origin signal
a = 5; b = 2; c = 8; % Some constants to use in our equation
y = a*x^2 + b*x + c; % Define a quadratic relationship between x and y

h = sig.plot(x,y);
for i = -50:1:50
  x.post(i)
end

%%
% TODO example using sin & pi

%% Logical operations
% Note that the short circuit operators && and || are not implemented in
% Signals
bool = x >= 5 & x < 10; 

sig.plot(x, bool, 'o');
for i = 1:15
  x.post(i)
end

%% mod, floor, ceil
even = mod(floor(x), 2) == 0;
odd = ~even;

h = sig.timeplot(x, even, odd);
for i = 1:15
  x.post(i)
end
clear h

%% Arrays
% You can create numerical arrays and matricies with Signals in an
% intuitive way.  NB: When ever you perform an operation one or more
% Signals objects, always expect a new Signals object to be returned.  In the
% below example we create a 1x3 vector Signals, X, which is not an array of
% Signals but rather a Signal that carries a numrical array as its value
X = [x 2*x 3];
X_sz = size(X);

h = [output(X), output(X_sz)];

x.post(5)

%% Matrix arithmatic
Xt = X';
Y = X.^3 ./ 2;

% For a full list see doc sig.Signal.  NB: Sometimes due to limitations of
% syntax, it's necessary to do away with syntactic sugar.  It is therefore
% worth remembering the basic functions, i.e. not(), plus(), times(), etc.

%% A note about Signals variables
% Signals are objects that constantly update their values each time the
% Signals they depend on update.  A Signal will not a take a value post-hoc
% after a new Signal takes a value.  Consider the following:
x.Node.CurrValue
y = x^2;
y.Node.CurrValue
x.post(3)
y.Node.CurrValue

% Likewise if you re-define a Signal, any previous Signals will continue
% using the old values and any future Signals will use the new values,
% regardless of whether the variable name is the same.
y = x^2;
a = y + 2;
y = x^3; % A new Signal object is assigned to the variable y
b = y + 2;

% Looking at the name of your Signals may help you here
% TODO use visualizations (sig.Visulizer)
y.Name
a.Name
b.Name

%% Signals can derive from multiple signals
% The above examples show how a signal can derive from one other signal,
% however a signal can be defined by any number of other signals as well as
% by constants.
% Mathematically, Signals can be viewed as variables which any time they
% take a new value, cause any equations dependent equations to be
% re-evaluated.

% Create some origin signals to post to
x = net.origin('x'); 
a = net.origin('a');
b = net.origin('b');
c = net.origin('c');

y = a*x^2 + b*x + c;
upperBound = max([abs(a), abs(b), abs(c)]) / abs(a) * (1 + sqrt(5))/2;

sig.timeplot(x, a, b, c, y, upperBound);

%% Indexing with Signals
A = net.origin('A');
a = A(1); % index a and assign to b
a.post(1:10); % assign a vector of values from 1 to 10

b.Node.CurrValue % 1

c = a(end);
d = a(1:5);
a.post(10:20); % assign new vector with values from 10 to 20
b.Node.CurrValue % 10
c.Node.CurrValue % 20
d.Node.CurrValue % [10 11 12 13 14]

% FIXME: This is for later
% a(1) = 5; % fail!
% a = a.subscriptable(); % only for structs
% a(1) = 1; % also fail

idx = net.origin('index');
e = a(idx);
a.post(10:20);
idx.post(5);
e.Node.CurrValue % 14

%% Use more complex functions with map
% It is not possible to call all functions with signals objects as inputs,
% and therefore expressions like fliplr(A), where A is a Signal will cause
% an error:
A = net.origin('A'); % Create an origin signal
B = fliplr(A); % Conversion to logical from sig.node.Signal is not possible

% Instead we can use the function map, which will call a given function
% with a Signal's current value as its input each time that signal take a
% new value
B = A.map(@fliplr);
A.post(eye(5));

% Sometimes your Signal must be in a different positional argument:
% delta = A.map(@(A)diff(A,1,2)); % Take 1st order difference over 2nd dimension
a = A.map(@(A)sum(A,2)); % Take sum over 2nd dimension
A.post(magic(3));

% fun.partial can be a convenient way to map a function where there are a
% number of constant variables in a function:
f = fun.partial(@sprintf, '%.1f%%'); % Returns a function handle which will call sprintf with the first argument as '%.1f%%' 
class(f)
y = x.map(f);
y1 = map(1-y, f);

% TODO for more complex anonymous function
% timeOutTracker = responseType.bufferUpTo(1000);
% timeOutCount = timeOutTracker.map(@(x) sum(x(find([1 x~=0],1,'last'):end)==0));


% Sometimes you want to derive a Signal whose value is always constant but
% nevertheless updates depending on another Signal, thus acting as a
% trigger for something.  This can be achieved by using a constant value
% instead of a function in map.  For example here we produce a signal that
% is always mapped to true and updates whenever its dependent value
% updates
updated = x.map(true);
% NB c.f. with at and skipRepeats

% Note that the if it's a value rather than a function handle, it is truely
% constant, even if it's the output of a function:
c = x.map(rand);
rnd = x.map(@(~)rand); % The tilda here means... 

%% Map multiple Signals through a function with mapn
% TODO
B = A.mapn(n, 1, @repmat);

% NB: Map will only assign the first output argument of the function to the
% resulting Signal

%% Filtering
% at, then, setTrigger, skipRepeats, keepWhen

%% More complex conditionals
% cond, iff, indexOfFirst

%% TODO MOVE SCAN HERE

%% Helpful methods
% delta, lag, buffer, bufferUpTo

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

%% TODO SetEpochTrigger

%% FIXME Move subscriptables here

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

%% Demonstration of scan
% Scan is a very powerful method that allows one to map a signal's current
% value and it's previous value through a function.  This allows one to 
%
net = sig.Net;
x = net.origin('x');

y = x.scan(@plus, 0);

sig.timeplot(x,y, 'tWin', 0)
for i = 1:10
  x.post(1)
end

%% The seed value may be a signal
x = net.origin('x');
seed = net.origin('seed');
y = x.scan(@plus, seed);

sig.timeplot(x, y, seed, 'tWin', 1, 'mode', [0 0 1])
seed.post(0); % Initialize seed with value
for i = 1:10
  if i == 5
    seed.post(0)
  end
  x.post(1)
end

%% Growing an array with scan
x = net.origin('x');
seed = net.origin('seed');
seed.post('!'); % Initialize seed with value
f = @(acc,itm) [itm acc]; % Prepend char to array
y = x.scan(f, seed);
h = y.output();
for i = 1:10
  x.post('>')
end

%% Introducing extra parameters
x = net.origin('x');
seed = net.origin('seed');
seed.post('!'); % Initialize seed with value
f = @(acc,itm,p1) [itm p1 acc]; % Prepend char to array
y = x.scan(f, seed, 'pars', '.'); % Pars may be signals or no
h = y.output();

x.post('>')

%% Paramters may be Signals

x = net.origin('x');
seed = net.origin('seed');
seed.post('0'); % Initialize seed with value
f = @(acc,itm,delim) strjoin({acc, itm}, delim); % Prepend char to array
y = x.scan(f, seed, 'pars', ' + '); % Pars may be signals or no
h = y.output();

x.post('1')
x.post('12')
x.post('18')
x.post('5')
x.post('8')

 %% When pars take new value accumulator function is not called!
x = net.origin('x');
seed = net.origin('seed');
p = net.origin('delimiter');
seed.post('0'); % Initialize seed with value
p.post(' + '); % Initialize seed with value
f = @(acc,itm,delim) strjoin({acc, itm}, delim); % Prepend char to array
y = x.scan(f, seed, 'pars', p); % Pars may be signals or no
h = y.output();

x.post('1')
x.post('12')
p.post(' - '); % Updating p doesn't affect scan
x.post('18')
x.post('5')
p.post(' * ');
x.post('8')

%% Scan can call any number of functions at the same time
x = net.origin('x');
y = net.origin('y');
z = net.origin('z');
seed = net.origin('seed');
seed.post(0); % Initialize seed with value
f1 = @plus; %
f2 = @minus; %
f3 = @times; %
v = scan(x, f1, y, f2, z, f3, seed); % Pars may be signals or no
h = v.output();

x.post(1) % 1
x.post(1) % 2
x.post(1) % 3

y.post(1) % 2
y.post(1) % 1

z.post(2) % 2
z.post(2) % 4
z.post(2) % 8

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