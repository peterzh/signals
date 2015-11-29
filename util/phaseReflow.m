function delta = phaseReflow(delta)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

daqCounterPeriod = 2^32;
daqCounterHalfPeriod = daqCounterPeriod/2;

if delta > 0 && delta > daqCounterHalfPeriod
  delta = delta - daqCounterHalfPeriod;
elseif delta < 0 && delta < -daqCounterHalfPeriod
  delta = delta + daqCounterHalfPeriod;
end

end

