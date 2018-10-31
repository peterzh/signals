function [layer, img] = imgLayer(pos, dims, orientation)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  phase = 0;
end

%% square
img = imread('\\zserver.cortexlab.net\Code\Rigging\ExpDefinitions\Miles\cat.jpeg');

layer = vis.emptyLayer();
layer.interpolation = 'nearest';
layer.texOffset = pos;
layer.texAngle = orientation;
layer.size = size(img);
layer.isPeriodic = false;

end