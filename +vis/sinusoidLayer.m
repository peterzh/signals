function [layer, img] = sinusoidLayer(azimuth, spatialFreq, phase, orientation)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  phase = 0;
end

%% (co)sinusoid of unit wavelength, from 0 to 1: 0.5*cos( 2*pi*x ) + 0.5

% If a single of cycle of a sinsusoid is sampled at 37 equally spaced
% points, linear interpolation between adjacent samples will have a max
% error < 0.5/255.
% An odd number means we hit the peak of the sinusoid == 1 at the centre
% pixel.
%
% So sample a full cycle at that resolution, changing along the x-axis, and
% only 1 sample tall in y.
np = 37;
p = single(linspace(-0.5, 0.5 - 1/np, np));
img = 0.5*cos(2*pi*p) + 0.5;

w = 1/spatialFreq; % width is dependent on spatial frequency (SF)
azi = (180*mod(phase,2*pi)/pi)/(spatialFreq*360) + azimuth;% azimuth is depdent on SF & phase

layer = vis.emptyLayer();
% layer.image = img;
layer.texOffset = [azi; 0];
layer.texAngle = orientation;
% it's full field by being periodic
layer.size = [w; 180];% full altitude coverage
layer.isPeriodic = true;

end

