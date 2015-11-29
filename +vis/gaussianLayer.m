function [layer, img] = gaussianLayer(pos, sigma)
%VIS.GAUSSIANLAYER Summary of this function goes here
%   Detailed explanation goes here

%% Gaussian of unit sigma: exp( -0.5*x^2 )

% If a Gaussian of unit sigma is sampled at 61 equally spaced points
% between x = +/-3.6, the values at the edges will be < 0.5/256, and linear
% interpolation between adjacent samples will have a max error < 0.5/256.
% An odd number means we hit the peak of the Gaussian == 1 at the centre
% pixel.
%
% Thus there is no point in sampling a Gaussian at a higher resolution or
% at more extreme points:
extend = 1;% increase this from one to avoid needing to repeat edges
xlimit = extend*18/5;% A gaussian is ~0.4/256 at this point
np = extend*61; % dx = ~0.12, max linear interp error = ~0.46/256

p = single(linspace(-xlimit, xlimit, np));
img = bsxfun(@times, exp( -0.5*p.^2 ), exp( -0.5*p.^2 )');

layer = vis.emptyLayer();
% layer.image = img;
layer.texOffset = pos;
layer.size = [(2*xlimit)*sigma(1); (2*xlimit)*sigma(2)];
layer.isPeriodic = false;

end

