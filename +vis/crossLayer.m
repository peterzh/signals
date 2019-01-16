function [layer, img] = crossLayer(pos, dims, orientation)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%% square
img = zeros(3, 3, 'single');
img(:,2) = 1; img(2,:) = 1;

layer = vis.emptyLayer();
layer.interpolation = 'nearest';
layer.texOffset = pos;
layer.texAngle = orientation;
layer.size = dims;
layer.isPeriodic = false;

end