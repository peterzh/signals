function driftingGrating(t, evts, pars, stimuli, inp, out, audio)
%driftingGrating A simple drifting grating flashed during each trial
%   Detailed explanation goes here

grating = vis.grating(t);    % we want a gabor grating patch
grating.phase = 2*pi*t*3; % with it's phase cycling at 3Hz

stimOff = evts.newTrial.delay(0.5); % stimOff occurs 0.5s after new trial starts
evts.endTrial = stimOff.delay(1);  % next trial should start 1s after stimOff
grating.show = evts.newTrial.to(stimOff);  % stimulus visible between trial onset & stimOff

stimuli.grating = grating;

end

