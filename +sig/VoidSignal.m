classdef VoidSignal < sig.Signal
  % sig.VoidSignal Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function mapped = map(this, f, varargin)
      mapped = this;
    end
    
    function mapped = map2(this, other, f, varargin)
      mapped = this;
    end
    
    function mapped = mapn(this, varargin)
      mapped = this;
    end
    
    function scanning = scan(this, f, seed)
      scanning = this;
    end
    
    function d = lag(this, n)
      d = this;
    end
    
    function d = delay(this, period)
      d = this;
    end
    
    function c = cond(this, varargin)
      c = this;
    end
    
    function s = at(this, when)
      s = this;
    end
    
    function s = keepWhen(this, when)
      s = this;
    end
    
    function h = onValue(this, fun)
      h = TidyHandle.empty;
    end
    
    function h = output(this)
      h = TidyHandle.empty;
    end
    
    function l = log(this, clockFun)
      l = this;
    end
    
    function id = identity(this)
      id = this;
    end
    
    function d = delta(this)
      d = this;
    end
    
    function nr = skipRepeats(this)
      nr = this;
    end
    
    function tr = setTrigger(set, release)
      tr = set;
    end
    
    function p = to(a, b)
      p = a;
    end
    
    function m = merge(varargin)
      m = varargin{1};
    end
    
    function b = bufferUpTo(this, nSamples)
      b = this;
    end
    
    function b = buffer(this, nSamples)
      b = this;
    end
    
    function f = indexOfFirst(varargin)
      f = varargin{1};
    end
    
    function s = selectFrom(this, varargin)
      s = this;
    end
  end
  
  methods (Access = private)
    function this = VoidSignal()
    end
  end

  methods (Static)
    function s = instance()
      persistent inst;
      if isempty(inst)
        inst = sig.VoidSignal;
      end
      s = inst;
    end
  end
  
end

