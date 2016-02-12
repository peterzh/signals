function [layer, img] = rectLayer(pos, dims, orientation)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  phase = 0;
end

%% square
img = zeros(3, 3, 'single');
img(2,2) = 1;

layer = vis.emptyLayer();
layer.interpolation = 'nearest';
layer.texOffset = pos;
layer.texAngle = orientation;
layer.size = 3*dims;
layer.isPeriodic = false;

end