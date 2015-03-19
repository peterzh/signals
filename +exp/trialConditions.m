function [pars, hasNext, repeatNum] = trialConditions(globalPars,...
  allCondPars, advanceTrial)
%EXP.PRESETCONDSERVER Summary of this function goes here
%   Detailed explanation goes here

% a new 1 (or true) in nextTrial means move on to the next condition,
% whereas a 0 (or false) means repeat this condition

nConds = allCondPars.map(@numel);

nextCondNum = advanceTrial.scan(@plus, 0); % this counter can go over nConds
hasNext = nextCondNum <= nConds;
% this counter cant go past nConds
repeatLastTrial = advanceTrial.keepWhen(hasNext);
condIdx = repeatLastTrial.scan(@plus, 0);
condIdx = condIdx.keepWhen(condIdx > 0);
condIdx.Name = 'condIdx';
repeatNum = repeatLastTrial.scan(@sig.scan.lastTrue, 0) + 1;
repeatNum.Name = 'repeatNum';

condPar = allCondPars(condIdx);

pars = globalPars.merge(condPar).scan(@mergeStruct, struct).subscriptable();
pars.Name = 'pars';

end

