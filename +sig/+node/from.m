function [nodes, isSignal] = from(srcs)
% sig.node.from Summary of this function goes here
%   Detailed explanation goes here


isSignal = cellfun(@(s) isa(s, 'sig.node.Signal'), srcs);
sgl = srcs{find(isSignal, 1)};
net = sgl.Node.Net;
nodes = sig.node.Node.empty;
for i = 1:numel(srcs)
  src = srcs{i};
  if isSignal(i)
    nodes(i) = src.Node;
  else
    nodes(i) = rootNode(net, toStr(srcs{i}));
    nodes(i).CurrValue = srcs{i};
  end
end


end

