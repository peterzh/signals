function [h] = fromSignal(packetSignal, sampleRate, bufferMax)
%AUDSTREAM.FROMSIGNAL Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  bufferMax = 2;
end

id = audstream.open(sampleRate);
audstream.start(id);
listener = packetSignal.onValue(fun.partial(@audstream.throttlePost, id,...
  bufferMax));
h = TidyHandle(@cleanup);

  function cleanup()
    disp('cleaning up audio stream');
    audstream.close(id);
    listener = [];
  end

end

