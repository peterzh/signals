function [val, valset] = flattenStruct(net, inputs, node, state)
%SIG.TRANSFER.MAP Summary of this function goes here
%   Detailed explanation goes here

% assumes inputs are [blueprint, field1inp, field2inp, ...]
% 1) fieldinp connections themselves will change as structinp changes
% 2) as fieldinp values change, only the current struct will change (its
% corresponding field will update), not connections

wvset = false(numel(inputs), 1);

%% read structinp - if changed, rewire fieldinps as appropriate
% if changed, build new struct prototype for new output, if not use
% retrieve existing value ready to update from any field updates
[wv, wvset(1)] = workingNodeValue(net, inputs(1)); 
if wvset(1) %blueprint input: structs of signals and other values
  % ISSUES: we need to be able to:
  % 1) update inputs in our corresponding signal... or maybe not?
  % 2) restore pre-transaction inputs on cancel - done
  state.unappliedInputChanges = true;
  structval = flatten(wv);
  
else % no new blueprint
  if state.unappliedInputChanges % previous input modifications must be undone
    [cv, cvset] = currNodeValue(net, inputs(1)); 
    if cvset
      structval = flatten(cv);
    else
      setNodeInputs(net, node, inputs(1));
      structval = currNodeValue(net, node);
    end
    state.unappliedInputChanges = false;
  else
    structval = currNodeValue(net, node);
  end
end

%% read each fieldinp, iteratively update output struct
for inp = 2:numel(inputs) %field inputs
  [wv, wvset(inp)] = workingNodeValue(net, inputs(inp));
  if wvset(inp)
    sbref = state.inputsToSubsref(inp);
    structval = subsasgn(structval, sbref, wv);
  end
end

if any(wvset)
  val = structval;
  valset = true;
else
  val = [];
  valset = false;
end

%% helper functions
  function structval = flatten(structBlueprint)    
    fn = fieldnames(structBlueprint);
    bpdatasz = [numel(fn) size(structBlueprint)];
    vals = cell(bpdatasz);
    bpvals = struct2cell(structBlueprint);
    isSig = cellfun(@(v)isa(v, 'sig.node.Signal'), bpvals);
    % the values of blueprint fields that aren't signals set immediately
    vals(~isSig) = bpvals(~isSig);
    % input nodes come from blueprint fields that are signals
    sigs = bpvals(isSig);
    sigidx = find(isSig);
    inpnodes = sig.node.Node.empty;
    for si = 1:numel(sigs)
      inpnodes(si) = sigs{si}.Node;
      [fieldidx, structidx] = ind2sub(bpdatasz, sigidx(si));
      % field inputs are 2:(nFields+1)
      state.inputsToSubsref(si+1) = substruct('()', {structidx}, '.', fn{fieldidx});
    end    
    % make the value structure that will take signal values as they come
    structval = cell2struct(vals, fn);
    % finally set inputs of this node to the nodes we just collected
    setNodeInputs(net, node, [inputs(1) [inpnodes.Id]]);
  end
end