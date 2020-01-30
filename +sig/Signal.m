classdef Signal < handle
  % SIG.SIGNAL Interface class for Signals.
  %   This class contains the methods for connecting signals within a
  %   network. These methods create a new signal or a TidyHandle object (a
  %   listener for Signals events). The abstract methods are mostly
  %   functional/reactive programming methods. The concrete methods are
  %   mostly overloaded builtin MATLAB functions. The principle subclass to
  %   this is SIG.NODE.SIGNAL.
  %
  %   Example: 
  %     create a Signals network and three origin signals
  %     net = sig.Net;
  %     os1 = net.origin('input 1'); 
  %     os2 = net.origin('input 2'); 
  %     os3 = net.origin('input 3');
  %
  % See also SIG.NODE.SIGNAL, SIG.NET
  %
  % *Note: when running the example code for the below methods, continue
  % from the 'Running Example' code written above
  %
  % @todo edit method descriptions
  % @body move long method examples/descriptions from here to
  % tutorials section, then reset examples/descriptions to something
  % similar Chris' originals
  
  %% Abstract methods
  methods (Abstract)
    
    % 'th = s1.onValue(f)' returns a TidyHandle 'th' which executes a
    % callback function 'f' whenever 's1' takes a value.
    %
    % Example:
    %   dispValLong = os1.onValue(@(x)... 
    %     fprintf('The value of this signal is %d\n',x));
    %   os1.post(5);

    h = onValue(this, fun)
    
    % 'th = output(s)' returns a TidyHandle listener which displays the
    % output of signal 's' whenever it takes a value (equivalent to 
    % 'th = s.onValue(@disp)').
    % 
    % Example:
    %   dispValShort = s.output;
    %   s.post('hello world'); % 'hello world' will be displayed
    %
    % See also SIG.SIGNAL.ONVALUE
    
    h = output(this)
    
    % 'ds = s1.identity()' returns a dependent signal 'ds' which takes as
    % value the value of 's1' whenever 's1' updates.
    %
    % *Note: If a signal 's2' is dependent on 's1', but both update during
    % the same propagation through the network, it may be hard to determine
    % which signal will update first. Since 's1' is required to update
    % first, we can create an identity signal 'dsI = s1.identity()', and
    % now force 's2' to be dependent on 'dsI' to ensure it will only ever
    % update after 's1'.
    %
    % Example:
    %   ds1 = os1.identity;
    %   ds1Out = output(ds1);
    %   os1.post(1); %'1' will be displayed
    
    id = identity(this)
    
    % 'ds = s1.at(s2)' returns a dependent signal 'ds' which takes the
    % current value of 's1' whenever 's2' takes any "truthy" value
    % (that is, a value not false or zero).
    %
    % Example:
    %   ds2 = os1.at(os2);
    %   ds2Out = output(ds2);
    %   os1.post(1);
    %   os2.post(0); % nothing will be displayed
    %   os2.post(2); % '1' will be displayed
    %   os2.post(false); % nothing will be displayed (though 'ds1' remains 1)
    
    s = at(this, when)
    
    % 'ds = what.keepWhen(when)' returns a dependent signal 'ds' which takes
    % the value of 'what' whenever 'when' evaluates true.
    %
    % Example:
    %   ds = s1.keepWhen(s2 > 1); % when s2 > 1, ds == s1
    
    s = keepWhen(what, when)
    
    % 'ds = s1.to(s2)' returns a dependent signal 'ds' which can only ever
    % take a value of 1 or 0. 'ds' initially takes a value of 1 when 's1'
    % takes a truthy value. 'ds' then alternates between updating to '0'
    % the first time 's2' updates to a truthy value after 's1' has updated
    % to a truthy value, and updating to '1' the first time 's1' updates
    % to a truthy value after 's2' has updated to a truthy value.
    %
    % Example:
    %   ds4 = os1.to(os2);
    %   ds4Out = output(ds4);
    %   os1.post(1); % '1' will be displayed
    %   os1.post(2); % nothing will be displayed
    %   os2.post(1); % '0' will be displayed
    %   os1.post(0); % nothing will be displayed
    %   os1.post(1); % '1' will be displayed
    
    p = to(a, b)
    
    % 'ds = s1.setTrigger(s2)' returns a dependent signal 'ds' which can
    % only ever take a value of 1. 'ds' initially updates to 1 when 's2' is
    % set to a truthy value, given that 's1' has a truthy value.
    % Additional updates of 'ds' take place whenever 's2' is set to a
    % truthy value, given that 's1' has been "reset" to a truthy value.
    %
    % Example:
    %   ds5 = os1.setTrigger(os2);
    %   ds5Out = output(ds5);
    %   os2.post(1); % nothing will be displayed
    %   os1.post(1); os2.post(2); % '1' will be displayed
    %   os2.post(3); % nothing will be displayed (value of 'ds13' remains 1)
    %   os1.post(2); os2.post(4); % '1' will be displayed
    
    tr = setTrigger(arm, release)
    
    % ds = s.map(f, [formatSpec]) returns a signal which takes the value
    % resulting from mapping function f onto the value in s (i.e. f(s)). If
    % f is not a function, f is mapped to ds whenever s takes a value.
    %
    % Examples:
    %   f = @(x) x.^2; % the function to be mapped
    %   ds = s.map(f); % ds = s^2
    %   m = s.map(pi); % m = pi whenever s updates
    
    m = map(this, f, varargin)
    
    % ds = s.map2(s2, f, [formatSpec]) returns a dependent signal ds which
    % takes the value resulting from applying the function f to the values
    % in s and s2 (i.e. f(s1, s2)).
    %
    % Example:
    %   f = @(x,y) x.*y + x; % the function to be mapped
    %   ds = s.map2(s2, f); % ds = s*s2 + s
    
    m = map2(this, other, f, varargin)
    
    % [ds1,...,dsN] = s1.mapn(s2..., sN, f, [formatSpec]) maps a variable
    % number of inputs to outputs through a function, f. The n dependent
    % signals (ds1-N) are assigned the positional output args of f in
    % order, i.e. [ds1,...,dsN] = f(s1,..., sN).
    %
    % Examples:
    %   % Derive Signal ds by mapping s1-s3 through anonymous function, f:
    %   f = @(x,y,z) x+y-z;
    %   ds = s.mapn(s2, s3, f); % ds = s + s2 - s3
    %
    %   % Assign the value 5 any time s1-3 update (similar to s.map(5))
    %   [ds1, ds2] = s1.mapn(s2, s3, @(varargin)deal(5)); 
    %
    %   % Derive 2 new signals by applying value of xx to meshgrid:
    %   [X, Y] = xx.mapn(@meshgrid);
    %
    % See also SIG.SIGNAL.MAP2
    
    m = mapn(this, varargin)

    % 'ds = s1.scan(f, init)' returns a dependent signal 'ds' which applies
    % an initial value 'init' to the first element in 's1' via the function 
    % 'f', and then applies each subsequent element in 's1' to the 
    % previous element, again via the function 'f', resulting in a running
    % total, whenever 's1' takes a value. If 'init' is a signal, it will
    % overwrite the current value of 'ds' whenever it updates.
    %
    % Example:
    %   f = @plus;
    %   ds9 = os1.scan(f, 5);
    %   ds9Out = output(ds9);
    %   os1.post([1 2 3]); % '[6 7 8]' will be displayed

    s = scan(this, f, seed)
    
    % 'ds = s1.skipRepeats' returns a dependent signal 'ds' which takes the
    % value of 's1' only when 's1' updates to a value different from
    % its current value.
    %
    % Example:
    %   ds10 = os1.skipRepeats;
    %   ds10Out = output(ds10);
    %   os1.post(1); % '1' will be displayed
    %   os1.post(1); % nothing will be displayed (value of 'ds14' remains 1)
    %   os1.post(2); % '2' will be displayed
    
    nr = skipRepeats(this)
    
    % 'ds = s1.delta' returns a dependent signal 'ds' which takes the value
    % of the difference between the current value of 's1' and its previous
    % value.
    %
    % Example:
    %   ds11 = os1.delta;
    %   ds11Out = output(ds11);
    %   os1.post(1);
    %   os1.post(10); % '9' will be displayed
    %   os1.post(5); % '-5' will be displayed
    
    d = delta(this)
    
    % 'ds = s1.bufferUpTo(n)' returns a dependent signal 'ds' which takes 
    % as value the last 'n' values 's1' took. When the number of updates
    % of 's1' is fewer than 'n', 'ds' takes as value all of those updates.
    % 
    % Example:
    %   ds12 = os1.bufferUpTo(3);
    %   ds12Out = output(ds12);
    %   os1.post(1); % '1' will be displayed
    %   os1.post(2); % '[1 2]' will be displayed
    %   os1.post(3); % '[1 2 3]' will be displayed
    %   os1.post(4); % '[2 3 4]' will be displayed
    %
    % See also SIG.SIGNAL.BUFFER
    
    b = bufferUpTo(this, nSamples)
    
    % 'ds = s1.buffer(n)' returns a dependent signal 'ds' which takes as
    % value the last 'n' values 's1' took. When the number of updates of
    % 's1' is fewer than 'n', 'ds' takes no value.
    %
    % Example:
    %   ds13 = os1.buffer(3);
    %   ds13Out = output(ds13);
    %   os1.post(1); % nothing will be displayed
    %   os1.post(2); % nothing will be displayed
    %   os1.post(3); % '[1 2 3]' will be displayed
    %   os1.post(4); % '[2 3 4]' will be displayed
    
    b = buffer(this, nSamples)
    
    % 'ds = s1.lag(n)' returns a dependent signal 'ds' which takes as value
    % the value of 's1' 'n+1' updates prior. In other words, 'ds'
    % "lags" behind 's1' by 'n' updates.
    %
    % Example:
    %   ds14 = os1.lag(2)
    %   ds14Out = output(ds14);
    %   os1.post(1); nothing will be displayed
    %   os1.post(2); nothing will be displayed
    %   os1.post(3); '3' will be displayed
    %
    % See also SIG.SIGNAL.BUFFER, SIG.SIGNAL.DELAY
    
    d = lag(this, n)
    
    % 'ds = s1.delay(n)' returns a dependent signal 'ds' which takes as 
    % value the value of 's1' after a delay of 'n' seconds, whenever 
    % 's1' updates.
    %
    % Example:
    %   ds15 = os1.delay(2);
    %   ds15Out = output(ds15);
    %   % 'runSchedule' is a 'Net' method that checks for and applies
    %   updates to signals that are being updated via a delay.
    %   os1.post(1); pause(2); net.runSchedule; % '1' will be displayed
    %
    %   See also SIG.NET.RUNSCHEDULE
    
    d = delay(this, period)
    
    % 'ds = s1.log' returns a dependent signal, 'ds' which takes as value a
    % structure with two fields, 'time' and 'value'. Each element in 'time'
    % is the time of the last update of 's1' (in seconds, via the PTB
    % GETSECS function), and the corresponding element in 'value' is the
    % value of that update. 'ds2' updates whenever 's1' takes a value.
    %
    % Example:
    %   ds16 = os1.log;
    %   ds16Out = output(ds16);
    %   os1.post(1); os1.post(2); os1.post(3); % a 1x3 struct array will be displayed
    
    l = log(this)
    
    % 'ds = s1.merge(s2...sN)' returns a dependent signal 'ds' which takes
    % as value the value of the most recent input signal to update. If 
    % multiple signals update during the same transaction, 'ds' will update
    % to the signal which is earlier in the input argument list 
    %
    % Example:
    %   ds1 = os1.at(os3);
    %   ds17 = os1.merge(os2,ds1,os3);
    %   ds17Out = output(ds17);
    %   os1.post(1); % '1' will be displayed
    %   os2.post(2); % '2' will be displayed
    %   os3.post(3); % '1' will be displayed
    
    m = merge(this, varargin)
    
    % 'ds = idx.selectFrom(option1...optionN)' returns a dependent signal
    % 'ds' which, whenever the signal 'idx' takes an integer value, takes
    % a value based on 1 of 3 cases. Case 1: When 'idx >= 1 && idx <= N', 
    % 'ds' takes the value of the input argument signal (in the input 
    % argument list) indexed with the value of 'idx.' Case 2: When 
    % 'idx == 0', 'ds = 0'. Case 3: When 'idx > N', 'ds' is not updated.
    % 
    % Example: 
    %   ds18 = os1.selectFrom(os2, os3);
    %   ds18Out = output(ds18);
    %   os2.post(2); os3.post(3);
    %   os1.post(1); % '2' will be displayed
    %   os1.post(2); % '3' will be displayed
    %   os1.post(3); % nothing will be displayed (value of 'ds7' remains 3)
    
    s = selectFrom(this, varargin)
    
    % 'ds = indexOfFirst(s1, ..., sN)' returns a dependent signal 'ds'
    % which takes as value the index of the first signal with a truthy
    % value in the input argument list of size 'N'. If no signal has a
    % truthy node value, then the node value of 'ds' = N+1.
    %
    % Example:
    %   ds19 = indexOfFirst(os1, os2, os3);
    %   ds19 = output(ds19);
    %   os1.post(0); % '4' will be displayed
    %   os3.post(1); % '3' will be displayed
    
    f = indexOfFirst(varargin)
    
    % 'ds = cond(pred1, val1, pred2, val2,...predN, valN)' returns a
    % dependent signal 'ds' which takes the corresponding value, 'val',
    % of the first true predicate, 'pred', in the 'pred, val' pair list
    % which 'cond' takes as arguments, whenever any signal in any predicate
    % in the predicate list takes a value ('pred1, val1' can be thought of
    % as a typical MATLAB name-value pair). If no predicates are true, 'ds'
    % does not take a value.
    %
    % Example:
    %   ds20 = cond(os1>0, 1, os2>0, 2);
    %   ds20Out = output(ds20);
    %   os1.post(0); % nothing will be displayed
    %   os1.post(1); % '1' will be displayed
    %   os2.post(1); % '1' will be displayed again
    %   os1.post(0); % '2' will be displayed
    
    c = cond(pred1, value1, varargin)
    
  end
  
  %% Overloaded MATLAB Methods
  methods
    function b = floor(a)
      % New signal carrying the input signal rounded down to the nearest
      % less than or equal to integer
      b = map(a, @floor, 'floor(%s)');
    end
    
    function a = abs(x)
      % New signal carrying the absolute value of the input signal
      a = map(x, @abs, '|%s|');
    end
    
    function a = sign(x)
      % New signal carrying the sign function of the input signal
      a = map(x, @sign, 'sgn(%s)');
    end
    
    function c = sin(a)
      % New signal carrying the sine function of the input signal
      c = map(a, @sin, 'sin(%s)');
    end
    
    function c = cos(a)
      % New signal carrying the cosine function of the input signal
      c = map(a, @cos, 'cos(%s)');
    end
    
    function c = uminus(a)
      % New signal carrying the negation of the input signal
      c = map(a, @uminus, '-%s');
    end
    
    function c = not(a)
      % New signal carrying the logical NOT of the input signal
      c = map(a, @not, '~%s');
    end
    
    function c = plus(a, b)
      % New signal carrying the addition between signals
      c = map2(a, b, @plus, '(%s + %s)');
    end
    
    function c = minus(a, b)
      % New signal carrying the subtraction between signals
      c = map2(a, b, @minus, '(%s - %s)');
    end
    
    function c = times(a, b)
      % New signal carrying the multiplication between signals
      c = map2(a, b, @times, '%s.*%s');
    end
    
    function c = mtimes(a, b)
      % New signal carrying the matrix multiplication between signals
      c = map2(a, b, @mtimes, '%s*%s');
    end
    
    function c = mrdivide(a, b)
      % New signal carrying the right-matrix division between signals
      c = map2(a, b, @mrdivide, '%s/%s');
    end
    
    function c = rdivide(a, b)
      % New signal carrying the right-array division between signals
      c = map2(a, b, @rdivide, '%s./%s');
    end
    
    function c = mpower(a, b)
      % New signal carrying the matrix power of 'a' to the 'b'
      c = map2(a, b, @mpower, '%s^%s');
    end
    
    function c = power(a, b)
      % New signal carrying the element-wise power of 'a' to the 'b'
      c = map2(a, b, @power, '%s.^%s');
    end
    
    function a = exp(x)
      % New signal carrying the element-wise exponential of 'a'
      a = map(x, @exp, 'exp(%s)');
    end
    
    function b = sqrt(a)
      % New signal carrying the square root of 'a'
      b = map(a, @sqrt, [char(8730), '(%s)']); % Square root symbol
    end
    
    function e = erf(x)
      % New signal carrying the error function of 'a'
      e = map(x, @erf, 'erf(%s)');
    end
    
    function c = mod(a, b)
      % New signal carrying the modulo operation between signals
      c = map2(a, b, @mod, '%s %% %s');
    end
    
    function y = vertcat(varargin)
      % New signal carrying the vertical concatenation of signals
      formatSpec = ['[' strJoin(repmat({'%s'}, 1, nargin), '; ') ']'];
      y = mapn(varargin{:}, @vertcat, formatSpec);
    end
    
    function y = horzcat(varargin)
      % New signal carrying the horizontal concatenation of signals
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
      % New signal carrying character-to-numeric converted array of the
      % input signal
      x = map(strSig, @str2num, 'str2num(%s)');
    end
    
    function b = round(a,N,type)
      % New signals carrying the result of rounding 'a' to 'N' digits
      if nargin < 2
        b = map(a, @round, 'round(%s)');
      elseif nargin < 3
        b = map2(a, N, @round, 'round(%s) to %s digits');
      else
        b = mapn(a, N, type, @round, 'round(%s) to %s digits by %s');
      end
    end
    
    function b = sum(a, dim)
      % New signal carrying the sum of all array elements in 'a' across
      % dimention 'dim'
      if nargin < 2
        b = map(a, @sum, 'sum(%s)');
      else
        b = map2(a, dim, @sum, 'sum(%s) over dim %s');
      end
    end
    
    function varargout = min(A,B,dim)
      % [M,I] = min(A,B,dim) New signal carrying the min value of inputs.
      if nargin < 2
        [varargout{1:nargout}] = mapn(A, @min, 'min(%s)');
      elseif nargin < 3
        [varargout{1:nargout}] = mapn(A, B, @min, 'min(%s,%s)');
      else
        [varargout{1:nargout}] = mapn(A, B, dim, @min, 'min(%s) over dim %s');
        for i = 1:nargout; varargout{i}.Node.DisplayInputs(2) = []; end
      end
    end
    
    function varargout = max(A,B,dim)
      % [M,I] = max(A,B,dim) New signal carrying the max value of its
      % inputs
      if nargin < 2
        [varargout{1:nargout}] = mapn(A, @max, 'max(%s)');
      elseif nargin < 3
        [varargout{1:nargout}] = mapn(A, B, @max, 'max(%s,%s)');
      else
        [varargout{1:nargout}] = mapn(A, B, dim, @max, 'max(%s) over dim %s');
        for i = 1:nargout; varargout{i}.Node.DisplayInputs(2) = []; end
      end
    end
    
    function b = fliplr(a)
      % New signal carrying 'a' with its rows flipped in the left-right
      % direction
      b = map(a, @fliplr, 'fliplr(%s)');
    end

    function b = flipud(a)
      % New signal carrying 'a' with its rows flipped in the up-down
      % direction
      b = map(a, @flipud, 'flipud(%s)');
    end


    function b = rot90(a, k)
      % New signal carrying 'a' rotated 90 degrees counter-clockwise 'k'
      % times
      if nargin < 2
        b = map(a, @rot90, 'rot90(%s)');
      else
        b = map2(a, k, @rot90, 'rot90(%s) %s times');
      end
    end
    
    function a = colon(i,j,k)
      if nargin < 3
        a = map2(i,j, @colon, '%s : %s');
      else
        a = mapn(i,j,k, @colon, '%s : %s : %s');
      end
    end
      
  end
  
end

