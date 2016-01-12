function f = fileFunction(functionPath, mfile)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  [functionPath, mfile] = fileparts(functionPath);
else
  [~, mfile] = fileparts(mfile);
end

f = @call;

  function varargout = call(varargin)
    origpath = addpath(functionPath);
    try
      f = str2func(['@' mfile]);
      [varargout{1:nargout}] = f(varargin{:});
    catch ex
      clear(mfile);
      path(origpath);
      rethrow(ex);
    end
    clear(mfile);
    path(origpath);
  end

end

