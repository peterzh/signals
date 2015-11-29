function C = horzcat(varargin)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

b = cellfun(@(a)isa(a, 'sig.Signal'), varargin);
if ~any(b)
  C = horzcat(varargin{:});
else
  C = mapn(varargin{:}, @(varargin)horzcat(varargin{:}));
end

end

