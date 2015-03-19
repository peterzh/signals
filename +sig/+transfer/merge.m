function [val, valset] = merge(net, inputs, node, ~)
% SIG.TRANSFER.MERGE Summary of this function goes here
%   Detailed explanation goes here

for inp = 1:numel(inputs)
  [v, set] = workingNodeValue(net, inputs(inp));
  if set
    val = v;
    valset = true;
    return;
  end
end
val = [];
valset = false;

end