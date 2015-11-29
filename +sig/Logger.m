classdef Logger < sig.Signal
  %SIG.LOGGER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  properties (Dependent)
    Values
    Times
  end
  
  properties (Access = private)
    pValues
    pTimes
    pNumValues = 0
    pCellBuffer
  end
  
  properties (Constant)
    InitBufferSize = 1000
  end
  
  methods
    function this = Logger(name, sources, cellBuffer)
      this = this@sig.Signal(name, sources);
      if nargin < 3 || ~cellBuffer
        this.pCellBuffer = false;
      else
        this.pCellBuffer = true;
        this.pValues = cell(1, this.InitBufferSize);
      end
      this.pTimes = zeros(1, this.InitBufferSize);
    end
    
    function v = get.Values(this)
      v = this.pValues(1:this.pNumValues);
    end
    
    function v = get.Times(this)
      v = this.pTimes(1:this.pNumValues);
    end

    function delete(this)
      fprintf('sig.Logger ''%s'' deleted\n', toStr(this));
    end
  end
  
  methods %(Access = protected)
    function apply(this)
      logValue(this, this.CurrValue);
      notify(this, 'NewValue');
    end
  end
  
  methods (Access = private)
    function logValue(this, value)
      t = GetSecs;
      if this.pCellBuffer
        newValue = {value};
        emptyValue = {[]};
      else
%         assert(numel(value) == 1,...
%           'For a non-cell buffer logger, the number of elements in each value must be one');
        if this.pNumValues == 0
          this.pValues = value;
          this.pValues(this.InitBufferSize) = value;
        end
        newValue = value;
        emptyValue = value;% use e.g. value to grow arbritrary array type
      end
      if numel(this.pValues) == this.pNumValues % need to grow array
        this.pValues(2*numel(this.pValues)) = emptyValue; % double its size
        this.pTimes(2*numel(this.pTimes)) = 0; % double its size
      end
      this.pTimes(this.pNumValues + 1) = t;
      this.pValues(this.pNumValues + 1) = newValue; % store the new value
      this.pNumValues = this.pNumValues + 1; % update the count
    end
  end
  
end

