function parsStruct = inferParameters(expdef)
%EXP.INFERPARAMETERS Summary of this function goes here
%   Detailed explanation goes here

% create some signals just to pass to the definition function and track
% which parameter names are used

net = sig.Net;
e = struct;
e.t = net.origin('t');
e.events = net.subscriptableOrigin('events');
e.pars = net.subscriptableOrigin('pars');
e.pars.CacheSubscripts = true;
e.visual = net.subscriptableOrigin('visual');
e.audio = net.subscriptableOrigin('audio');
e.inputs = net.subscriptableOrigin('inputs');
e.outputs = net.subscriptableOrigin('outputs');

try
  expdef(e.t, e.events, e.pars, e.visual, e.inputs , e.outputs);
  paramNames = e.pars.Subscripts.keys';
  parsStruct = cell2struct(cell(size(paramNames)), paramNames);
  parsStruct.numRepeats = 0; % add 'numRepeats' parameter
  parsStruct.defFunction = expdef;
  parsStruct.type = 'Custom';
catch ex
  net.delete();
  rethrow(ex)
end

net.delete();


end