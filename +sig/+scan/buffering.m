function f = buffering(maxSamples)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

f = @buffer;

  function buff = buffer(buff, val)
    if numel(buff) == maxSamples
      buff = [buff(2:end) val];
    else
      buff = [buff val];
    end
  end

end

