function f = structBuilder(varargin)
%STRUCTBUILDER Summary of this function goes here
%   Detailed explanation goes here

names = varargin;
f = @buildit;

  function s = buildit(varargin)
    fieldvaluepairs = [names; varargin];
    s = struct(fieldvaluepairs{:});
  end

end

