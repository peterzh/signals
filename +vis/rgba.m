function [img, sz] = rgba(colour, alpha)
%RGBA Summary of this function goes here
%   Detailed explanation goes here

h = max(size(colour, 1), size(alpha, 1));
w = max(size(colour, 2), size(alpha, 2));

sz = [w h];

if ~isscalar(colour) && size(colour, 3) == 1
  colour = repmat(colour, [1 1 3]);
end

img = zeros(h, w, 4, 'single');

img(:,:,1:3) = colour;
img(:,:,4) = alpha;

end

