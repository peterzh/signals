function C = vertcat(varargin)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

b = cellfun(@(a)isa(a, 'sig.Signal'), varargin);
if ~any(b)
  C = vertcat(varargin{:});
else
  C = mapn(varargin{:}, @(varargin)vertcat(varargin{:}));
end

end

