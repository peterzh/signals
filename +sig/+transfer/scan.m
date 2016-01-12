function [val, valset] = scan(net, input, node, funcs)
% SIG.TRANSFER.SCAN Summary of this function goes here
%   Detailed explanation goes here

% always assumes inputs: [item1, item2, ...., seed]
%% deal with a new seed, if any
[seedwv, seedwvset] = workingNodeValue(net, input(end));
if seedwvset
  val = seedwv;
  valavail = true;
  valset = true;
else
  [val, valavail] = currNodeValue(net, node);
  valset = false;
end
%% deal with a new element, if any
nElemInputs = numel(funcs);
for ii = 1:nElemInputs
  [itemwv, itemwvset] = workingNodeValue(net, input(ii));
  f = funcs{ii};
  if valavail && itemwvset
    % Canonical line: call scan function with current accumulator value (ie
    % current node value) and the new input value. New output is revised
    % accumulator value
    val = f(val, itemwv);
    valset = true;
  end
end

end