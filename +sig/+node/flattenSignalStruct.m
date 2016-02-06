function [structVal, inpNodes, fieldIdxs, structIdxs] = flattenSignalStruct(blueprint)
%UNTITLED Summary of this function goes here

%   `structVal` is initial structure made from flattening the blueprint
%   `inpNodes` is the list of node IDs that can update the structure
%   `fieldIdxs` linear index into structure that each input node updates
%   `structIdxs` linear index into structure that each input node updates

fieldNames = fieldnames(blueprint);
bpdatasz = [numel(fieldNames) size(blueprint)];
vals = cell(bpdatasz);
bpvals = struct2cell(blueprint);
isSig = cellfun(@isaSignal, bpvals);
% the values of blueprint fields that aren't signals set immediately
vals(~isSig) = bpvals(~isSig);
% get nodes from blueprint fields that are signals
sigs = bpvals(isSig);
sigidx = find(isSig);
inpNodes = zeros(1, numel(sigs)); % IDs of nodes
fieldIdxs = zeros(1, numel(sigs)); % IDs of nodes
structIdxs = zeros(1, numel(sigs)); % IDs of nodes
for si = 1:numel(sigs)
  n = node(sigs{si});
  inpNodes(si) = n.Id;
  [fieldIdxs(si), structIdxs(si)] = ind2sub(bpdatasz, sigidx(si));
end
% make the value structure that will take signal values as they come
structVal = cell2struct(vals, fieldNames);

end
%% Helper function
function b = isaSignal(v)
b = isa(v, 'sig.node.Signal');
end

