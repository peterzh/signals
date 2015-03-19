classdef Registry < sig.Registry
  %audstream.Registry Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Handles
  end
  
  properties (SetAccess = private)
    SampleRate
  end
  
  methods
    function this = Registry(sampleRate)
      this.SampleRate = sampleRate;
    end

    function value = entryAdded(this, name, value)
      this.Handles = [this.Handles audstream.fromSignal(value, this.SampleRate)];
    end
  end
  
end

