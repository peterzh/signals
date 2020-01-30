function s = toStr(v)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

if ischar(v)
  s = v;
elseif isempty(v)
  s = '[]';
elseif isstring(v)
  s = char(v);
elseif isobject(v)
  if any(strcmp(methods(v), 'str'))
    s = str(v);
  elseif any(strcmp(properties(v), 'Name'))
    s = v.Name;
  else
    s = class(v);
  end
elseif isnumeric(v)
  s = num2str(v);
elseif islogical(v)
  if numel(v) == 1
    if v
      s = 'true';
    else
      s = 'false';
    end
  else
    s = num2str(v);
  end
elseif isstruct(v)
  warning('toStr:isstruct:Unfinished', 'todo: implement toStr on structs');
  s = ['<' strJoin(fieldnames(v), ',') '>'];
elseif isa(v, 'function_handle')
  s = func2str(v);
  if s(1) ~= '@'
    s = ['@' s];
  end
end


end

