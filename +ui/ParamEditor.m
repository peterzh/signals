classdef ParamEditor < handle
  %UNTITLED2 Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    UI
  end
  
  methods
    function obj = ParamEditor()
      obj.UI = ui.FieldPanel;
    end
    
    function buildUI(obj, pars)
      c = obj.UI;
      names = pars.GlobalNames;
      for ni = 1:numel(names)
        addField(c, names(ni));
      end
    end
  end
  
end

