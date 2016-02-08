function layer = emptyLayer(n)
%VIS.EMPTYLAYER Summary of this function goes here
%   Detailed explanation goes here

layer = struct;
layer.show = false;
% layer.colour = 0;
% layer.alpha = 1;
layer.textureId = [];
layer.pos = [0 0];
layer.size = [0 0];
layer.viewAngle = 0;
layer.texAngle = 0;
layer.texOffset = [0 0];
layer.isPeriodic = true;
layer.blending = 'source';
layer.minColour = [0 0 0 0];
layer.maxColour = [1 1 1 1];
layer.colourMask = [true true true true];
layer.interpolation = 'linear';
layer.rgba = [];
layer.rgbaSize = [];

if nargin > 0 
  layer = repmat(layer, 1, n);
end

end

