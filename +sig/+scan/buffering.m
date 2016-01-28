function f = buffering(maxSamples)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

f = @buffer;

  function buff = buffer(val, buff)
    if size(buff, 2) == maxSamples
      buff = cat(2, buff(:,2:end), val);
    else
      buff = [buff val];
    end
  end

end

