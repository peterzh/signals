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

