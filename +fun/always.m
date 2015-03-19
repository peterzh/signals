function f = always(v)
%FUN.ALWAYS Summary of this function goes here
%   Detailed explanation goes here

f = @fun;

  function res = fun(~)
    res = v;
  end

end

