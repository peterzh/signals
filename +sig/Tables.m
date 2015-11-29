classdef Tables < handle
  %UNTITLED Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    CurrValues
    CurrValuesPresent
    WorkingValues
    WorkingValuesPresent
    Targets
    FreeIdx
  end
  
  methods
    function this = Tables(n)
      this.CurrValues = cell(n, 1);
      this.CurrValuesPresent = false(n, 1);
      this.WorkingValues = cell(n, 1);
      this.WorkingValuesPresent = false(n, 1);
      this.Targets = cell(n, 1);
      this.FreeIdx = n:-1:1;
    end
    
    function i = alloc(this)
      i = this.FreeIdx(end);
      this.FreeIdx(end) = [];
    end
  end
  
  methods (Static)
    
  end
  
end

