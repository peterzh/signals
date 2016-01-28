classdef Signal < handle
  % sig.Signal Summary of this class goes here
  %   Detailed explanation goes here
  
  methods (Abstract)
    % New signal that samples the value from this signal when another updates
    %
    % [s] = what.at(when) returns a new signal s that takes the current
    % value of signal 'what' at the moment signal 'when' gets a new value.
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
    % result from mapping values in this signal s using the function f.
    %
    % Example:
    %   s = sig.SimpleSignal;
    %   ms = s.map(@(v)2*v); % ms will always have twice the value of s
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
    
    % Derive a signal by 'scanning and accumulating' values from another
    %
    % [sc] = s.SCAN(f, initacc) returns a new signal sc whose values result
    % from applying each new value from signal s together with the previous
    % value in sc to function f.
    %
    % Example:
    %   s = sig.SimpleSignal;
    %   sc = s.scan(@plus, 0); % sc will contain a running total from s
    %
    % See also total
    s = scan(this, f, seed)
    
    % New signal carrying the value associated with the first currently true predicate
    %
    % [c] = cond(pred1, value1, [pred2], [value2],...)
    c = cond(pred1, value1, varargin)
    
    % todo: document
    s = selectFrom(this, varargin)
    
    % todo: document
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
    % Note: if multiple signals update during the same transaction, the
    % merged signal will only get one signal's value (and which it will be
    % is undefined).
    m = merge(this, varargin)
    
    % New signal that's true when one signal is true until another is true
    p = to(a, b)
    
    % todo: document
    tr = setTrigger(arm, release)
    
    % todo: document
    nr = skipRepeats(this)
    
    % New signal that follows another, but is always n samples behind
    %
    %
    d = lag(this, n)
    
    % New signal with the difference between the last two source samples
    d = delta(this)
    
    % New signal that follows another, but delayed in time
    %
    %
    d = delay(this, period)
    
    % todo: document
    id = identity(this)
    
    l = log(this)
    
    % todo: document
    h = onValue(this, fun)
    
    % todo: document
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

