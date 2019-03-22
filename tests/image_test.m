% preconditions
net = sig.Net;
t = net.origin('testNode');
testImages = load('imdemos.mat');
% pth = fileparts(which('cameraman.tif'));
% 'cell.tif'
% 'circlesBrightDark.png'
% 'coloredChips.png'

%% Test 1: Rescale MATLAB double array
img = double(testImages.circles);

elem = vis.image(t, img)

%% Test 2: Source image defined as a path
elem = vis.image(t, 'cell.tif')

%% Test 3: Source image as Signal

%% Test 4: 