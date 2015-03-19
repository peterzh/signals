function [val, valset] = keepWhen(net, inputs, node, ~)
% SIG.TRANSFER.KEEPWHEN Summary of this function goes here
%   Detailed explanation goes here

% always assumes two inputs: [what, when]

% get latest 'when' value
[when, whenwvset] = workingNodeValue(net, inputs(2));
if ~whenwvset
  [when, whencvset] = currNodeValue(net, inputs(2));
end
% we gate on the latest value existing and being truthy
if whenwvset || whencvset
  if when % if 'when' is truthy (i.e. not false or zero)...
    % ...get latest 'what' value
    [what, whatset] = workingNodeValue(net, inputs(1));
    % has a new 'what' value been set?
    if whatset % if so, set working output to it
      val = what;
      valset = true;
      return % only code path that sets a working output value
    end
  end
end
%all codepaths end here, but one
% no output
val = [];
valset = false;

end