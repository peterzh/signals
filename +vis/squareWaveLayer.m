function [layer, img] = squareWaveLayer(azimuth, spatialFreq, phase,...
  orientation)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  phase = 0;
end

%% square wave grating unit wavelength, from 0 to 1
img = [0 1];

w = 1/spatialFreq; % width is dependent on spatial frequency (SF)
azi = (180*mod(phase - pi/2, 2*pi)/pi)/(spatialFreq*360) + azimuth;% azimuth is depdent on SF & phase

layer = vis.emptyLayer();
layer.interpolation = 'nearest';
layer.texOffset = [azi; 0];
layer.texAngle = orientation;
% it's full field by being periodic
layer.size = [w; 180];% full altitude coverage
layer.isPeriodic = true;

end

