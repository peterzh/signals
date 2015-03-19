function [val, valset] = scanAsArgs(net, input, node, f)
% SIG.TRANSFER.SCANASARGS Summary of this function goes here
%   Detailed explanation goes here

[wv, wvset] = workingNodeValue(net, input); % assumes one input only
if wvset
  % Canonical line: call scan function with current accumulator value (ie
  % current node value) and the args from the new value packet. New output
  % is revised accumulator value
  val = f(currNodeValue(net, node), wv{:});
  valset = true;
else % no new input -> no new output
  val = [];
  valset = false;
end

end