function [val, valset] = schedule(net, input, node, ~)
% SIG.TRANSFER.SCHEDULE Summary of this function goes here
%   Detailed explanation goes here

% inputs are assumed to be [what, delay]
%% get latest value from 'delay' input
[delay, delayset] = workingNodeValue(net, input(2));
if ~delayset
  [delay, delayset] = currNodeValue(net, input(2));
end
%% working value from 'what' input
[what, whatset] = workingNodeValue(net, input(1)); % assumes one input only
%% if new 'what' and any 'delay' values are available, set output
if whatset && delayset
  val = {what delay}; % a schedule 'packet'
  valset = true;
else
  val = [];
  valset = false;
end

end