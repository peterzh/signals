function [val, valset] = map(net, input, node, f)
%SIG.TRANSFER.MAP Summary of this function goes here
%   Detailed explanation goes here

[wv, wvset] = workingNodeValue(net, input);% assumes one input only
if wvset
  % canonical line: call map function with latest input. new output is
  % result from map
  val = f(wv);
  valset = true;
else % input has no value -> no output value
  val = [];
  valset = false;
end

end