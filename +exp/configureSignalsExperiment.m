function e = configureSignalsExperiment(paramStruct, rig)
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here

%% Create the experiment object
e = exp.SignalsExp(paramStruct);
e.Type = paramStruct.type; %record the experiment type

%% Generate audio samples at device sample rate
% audSampleRate = aud.rate(rig.audio);

%% Confgiure the experiment with the necessary rig hardware
e.useRig(rig);

end

