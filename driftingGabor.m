function flashedGrating(t, evts, pars, vs, inp, out, audio)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

grating = vis.grating(t);    % we want a gabor grating patch
grating.phase = 2*pi*t*3; % with it's phase cycling at 3Hz

stimOff = evts.newTrial.delay(0.5); % stimOff occurs 0.5s after new trial starts
evts.endTrial = stimOff.delay(1);  % next trial should start 1s after stimOff
grating.show = evts.newTrial.to(stimOff);  % stimulus visible between trial onset & stimOff

vs.grating = grating;

end

