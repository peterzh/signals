function throttlePost(streamId, bufferMax, packet)
%AUDSTREAM.THROTTLEPOST Summary of this function goes here
%   Detailed explanation goes here

usedSlots = audstream.info(streamId);
if usedSlots < bufferMax
  audstream.post(streamId, packet);
end

end

