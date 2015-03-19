function [val, valset] = identity(net, input, node, f)
%SIG.TRANSFER.IDENTITY Summary of this function goes here
%   Detailed explanation goes here

[wv, wvset] = workingNodeValue(net, input);% assumes one input only
if wvset
  % canonical line: identity: input->output 
  val = wv;
  valset = true;
else % input has no value -> no output value
  val = [];
  valset = false;
end

end