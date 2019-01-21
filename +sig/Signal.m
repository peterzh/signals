classdef Signal < handle
  % sig.Signal Abstract class defining how Signals objects can interact
  % with one another
  %   This class contains the methods that define how a Signals object can
  %   be manipulated.  The principle subclass to this is SIG.NODE.SIGNAL,
  %   which inherhits these methods.  All concrete methods defined here 
  %   effectively overload builtin functions using the map function with a
  %   format spec to allow straightforward syntax.
  %
  %     Example: 
  %       net = sig.Net; % Create network
  %       simpleSignal = net.origin('simpleSignal'); % Create signal one
  %       simpleSignal2 = output(simpleSignal^2); % display result
  %       simpleSignal.post(5);
  %       >> 25
  %       simpleSignal.post(2);
  %       >> 4
  %       
  %
  % See also sig.node.Signal, sig.node.Signal/mapn
  
  methods (Abstract)
    % New signal that samples the value from this signal when another updates
    %
    % [s] = what.at(when) returns a new signal s that takes the current
    % value of signal 'what' at the moment signal 'when' gets a new, truthy
    % value (that is, a value not false or zero).
    %
    % Example:
    %   x = sig.SimpleSignal;
    %   t = sig.sampler(true, 0.010); % a new 'true' every 10ms
    %   sx = x.at(t); % sc will sample x's value every 10ms
    %
    % See also keepWhen
    s = at(this, when)
    
    % New signal that tracks another signal when a gating signal is true
    %
    % [s] = what.keepWhen(when) returns a new signal s that takes the
    % values of what whenever the signal when is currently not false.
    s = keepWhen(what, when)
    
    % Derive a signal by mapping the values from another
    %
    % m = s.MAP(f, [formatSpec]) returns a new signal m whose values
    % result from mapping values in this signal s using the function f.  If
    % f is not a function, m takes the value of f each time s updates.
    %
    % Example:
    %   s = sig.SimpleSignal;
    %   ms = s.map(@(v)2*v); % ms will always have twice the value of s
    %
    % Example 2:
    %   s = sig.SimpleSignal;
    %   tr = s.map(true); % tr will be true each time s updates
    %
    % See also map2, mapn
    m = map(this, f, varargin)
    
    % Derive a signal by mapping the values from two signals
    m = map2(this, other, f, varargin)
    
    % Derive a signal by mapping the values from n signals
    %
    % m = s1.MAPN([s2], [s3], ..., f, [formatSpec]) returns a new signal
    % m whose values result from mapping values in this and an arbitrary
    % number of other signals by applying function f.
    %
    % Example:
    %   s = sig.SimpleSignal;
    %   ms = s.map(@(v)2*v); % ms will always have twice the value of s
    %
    % See also map, map2
    m = mapn(this, varargin)
    
    % Create a signal updated iteratively from scanning this signal.
    %
    % acc = items.scan(f, init) returns a new signal acc whose values
    % result from applying each new value from signal items together with
    % the previous value in acc to function f, called as newacc = f(itemval,
    % accval). init sets the initial value of acc, and can be a value or a
    % signal. If a signal, init will overwrite the current value of acc
    % whenever it changes.
    %
    % Example:
    %   y = x.scan(@plus, 0); % y will contain running total of values in x
    %
    % See also total
    s = scan(this, f, seed)
    
    % New signal carrying the value associated with the first currently true predicate
    %
    % [c] = cond(pred1, value1, [pred2], [value2],...)
    c = cond(pred1, value1, varargin)
    
    % Returns the value of the input signal indexed by this
    % The resulting signal samples a new value if either the index signal
    % (this) or the indexed signal changes
    s = selectFrom(this, varargin)
    
    % Returns the index of the first input to evaluate true
    %
    % [idx] = indexOfFirst(a, b, [...], n) Returns number of first truthy
    % input in list.  If no match is found, then idx = n+1.  NB: The order
    % of inputs is important, e.g. if a is undefined (has no value) but b
    % is true, idx = n+1.  Vice versa would yeild idx = 1.
    f = indexOfFirst(varargin)
    
    % New signal carrying the last n samples from another
    %
    % [sc] = s.bufferUpTo(n) returns a new signal sc whoes values are
    % the last n values signal s took.  Unlike buffer, bufferUpTo immediately
    % returns new signal even if n samples have not yet been collected.
    % 
    % See also buffer
    b = bufferUpTo(this, nSamples)
    
    % New signal carrying the last n samples from another
    %
    % [sc] = s.buffer(n) returns a new signal sc whoes values are
    % the last n values signal s took.  Unlike bufferUpTo, buffer only 
    % returns new signal when n samples have been collected.
    % See also bufferUpTo
    b = buffer(this, nSamples)
    
    % New signal that gets all values from n signals
    %
    % This signal takes the value of the last input signal to update.
    % Note: if multiple signals update during the same transaction, the
    % merged signal will only get one signal's value (and which it will be
    % is undefined).
    m = merge(this, varargin)
    
    % New signal that's true when one signal is true until another is true
    p = to(a, b)
    
    % New signal that's true when a 'release' signal is true, given that a
    % third signal 'arm' was true
    %
    % tr = setTrigger(arm, release) samples true once and only once when
    % release is true, given that arm was true.  This signal doesn't sample
    % another value until 'armed' again.
    tr = setTrigger(arm, release)
    
    % New signal that only updates its values when the new value is
    % different from its current one
    nr = skipRepeats(this)
    
    % New signal that follows another, but is always n samples behind
    %
    % See also delay
    d = lag(this, n)
    
    % New signal with the difference between the last two source samples
    d = delta(this)
    
    % New signal that follows another, but delayed in time
    %
    %
    d = delay(this, period)
    
    % Mathmematical identity function, i.e. output == input
    % 
    % When two signals update at the same time, the order is undefined.
    % Sometimes it is required that one signal updates first, in which case
    % the use of identity can help.
    % 
    % Example:
    %   endTrial = repeat.at(stimOff) 
    %   % endTrial and stimOff update during the same propagation through 
    %   % the network.  stimOff may update AFTER endTrial, which is
    %   % undesirable.
    %   endTrial = repeat.at(stimOff.identity())
    %   % Now endTrial is likely to update just after stimOff takes a value
    id = identity(this)
    
    % Returns a struct with a timestamp and value for every update
    l = log(this)
    
    % Define a callback function for when signal takes a value
    h = onValue(this, fun)
    
    % Display the current value each time a signal updates
    h = output(this)
  end
  
  methods
    function b = floor(a)
      b = map(a, @floor, 'floor(%s)');
    end
    
    function a = abs(x)
      a = map(x, @abs, '|%s|');
    end
    
    function a = sign(x)
      a = map(x, @sign, 'sgn(%s)');
    end
    
    function c = sin(a)
      c = map(a, @sin, 'sin(%s)');
    end
    
    function c = cos(a)
      c = map(a, @cos, 'cos(%s)');
    end
    
    function c = uminus(a)
      c = map(a, @uminus, '-%s');
    end
    
    function c = not(a)
      c = map(a, @not, '~%s');
    end
    
    function c = plus(a, b)
      c = map2(a, b, @plus, '(%s + %s)');
    end
    
    function c = minus(a, b)
      c = map2(a, b, @minus, '(%s - %s)');
    end
    
    function c = mtimes(a, b)
      c = map2(a, b, @mtimes, '%s*%s');
    end
    
    function c = times(a, b)
      c = map2(a, b, @times, '%s.*%s');
    end
    
    function c = mrdivide(a, b)
      c = map2(a, b, @mrdivide, '%s/%s');
    end
    
    function c = rdivide(a, b)
      c = map2(a, b, @rdivide, '%s./%s');
    end
    
    function c = mpower(a, b)
      c = map2(a, b, @mpower, '%s^%s');
    end
    
    function c = power(a, b)
      c = map2(a, b, @power, '%s.^%s');
    end
    
    function c = mod(a, b)
      c = map2(a, b, @mod, '%s %% %s');
    end
    
    function y = vertcat(varargin)
      formatSpec = ['[' strJoin(repmat({'%s'}, 1, nargin), '; ') ']'];
      y = mapn(varargin{:}, @vertcat, formatSpec);
    end
    
    function y = horzcat(varargin)
      formatSpec = ['[' strJoin(repmat({'%s'}, 1, nargin), ' ') ']'];
      y = mapn(varargin{:}, @horzcat, formatSpec);
    end
    
    function c = eq(a, b, handleComparison)
      % New signal carrying the current equality (==) between signals
      
      if nargin < 3 || ~handleComparison
        c = map2(a, b, @eq, '%s == %s');
      else
        c = eq@handle(a, b);
      end
    end
    
    function c = ge(a, b)
      % New signal carrying the current inequality (>=) between signals
      
      c = map2(a, b, @ge, '%s >= %s');
    end
    
    function c = gt(a, b)
      % New signal carrying the current inequality (>) between signals
      
      c = map2(a, b, @gt, '%s > %s');
    end
    
    function c = le(a, b)
      % New signal carrying the current inequality (<=) between signals
      
      c = map2(a, b, @le, '%s <= %s');
    end
    
    function c = lt(a, b)
      % New signal carrying the current inequality (<) between signals
      
      c = map2(a, b, @lt, '%s < %s');
    end
    
    function c = ne(a, b, handleComparison)
      % New signal carrying the current non-equality (~=) between signals
      
      if nargin < 3 || ~handleComparison
        c = map2(a, b, @ne, '%s ~= %s');
      else
        c = ne@handle(a, b);
      end
    end
    
    function c = and(a, b)
      % New signal carrying the logical AND between signals
      
      c = map2(a, b, @and, '%s & %s');
    end
    
    function c = or(a, b)
      % New signal carrying the logical OR between signals
      
      c = map2(a, b, @or, '%s | %s');
    end
    
    function b = strcmp(s1, s2)
      % New signal carrying the result of string comparison
      b = map2(s1, s2, @strcmp, 'strcmp(%s, %s)');
    end
    
    function b = transpose(a)
      % New signal carrying the result of transposing source values
      b = map(a, @transpose, '%s''');
    end
    
    function x = str2num(strSig)
      x = map(strSig, @str2num, 'str2num(%s)');
    end
  end
  
end

