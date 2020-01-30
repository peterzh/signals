function elem = grating(t, grating, window)
%VIS.GRATING Returns a Signals grating stimulus defining a grating texture
%  Produces a visual element for parameterizing the presentation of a
%  grating. Produces a grating that can be either sinusoidal or
%  square-wave, and may be windowed by a Gaussian stencil, producing a
<<<<<<< HEAD
%  Gabor patch, or a Square stencil.
=======
%  Gabor patch.
>>>>>>> 602468e79dddf91a8776cf35762cb330f9c4b8e8
%
%  Inputs:
%    't' - The "time" signal. Used to obtain the Signals network ID.
%      (Could be any signal within the network - 't' is chosen by
%      convention).
%    'grating' - A char array defining the nature of the grating. Options
%      are 'sinusoid' (default) or 'squarewave'.
%    'window' - A char array defining the type of windowing applied.
<<<<<<< HEAD
%      Options are 'gaussian' (default) or 'square', or 'none'.
=======
%      Options are 'gaussian' (default) or 'none'.
>>>>>>> 602468e79dddf91a8776cf35762cb330f9c4b8e8
%
%  Outputs:
%    'elem' - a subscriptable signal containing fields which parametrize
%      the stimulus, and a field containing the processed texture layer.
%      Any of the fields may be a signal.
%
%  Stimulus parameters (fields belonging to 'elem'):
%    'grating' - see above
%    'window' - see above
%    'azimuth' - the azimuth of the image (position of the centre pixel in
%     visual degrees).  Default 0
%    'altitude' - the altitude of the image (position of the centre pixel
%     in visual degrees). Default 0
%    'sigma' - if window is Gaussian, the size of the window in visual
<<<<<<< HEAD
%      degrees. If window is Square, the size of the rectangle.
=======
%      degrees. If window is rectangular, the size of the rectangle.
>>>>>>> 602468e79dddf91a8776cf35762cb330f9c4b8e8
%      Must be an array of the form [width height]. Default [10 10]
%    'phase' - the phase of the grating in visual degrees.  Default 0
%    'spatialFreq' - the spatial frequency of the grating in cycles per
%      visual degree.  Default 1/15
%    'orientation' - the orientation of the grating in degrees. Default 0
%    'colour' - an array defining the intensity of the red, green and blue
%      channels respectively. Values must be between 0 and 1.
%      Default [1 1 1]
%    'contrast' - the normalized contrast of the grating (between 0 and 1).
%      Default 1
%    'show' - a logical indicating whether or not the stimulus is visible.
%      Default false
%
%  See Also VIS.EMPTYLAYER, VIS.PATCH, VIS.IMAGE, VIS.CHECKER6, VIS.GRID

% Define our default inputs
if nargin < 3 || isempty(window)
    window = 'gaussian';
end
if nargin < 2 || isempty(grating)
    grating = 'sinusoid';
end

% Add a new subscriptable origin signal to the same network as the input
% signal, 't', and use this to store the stimulus texture layer and
% parameters
elem = t.Node.Net.subscriptableOrigin('gabor');
% Set some defaults for the stimulus
elem.grating = grating;
elem.window = window;
elem.azimuth = 0;
elem.altitude = 0;
elem.sigma = [10 10]';
elem.spatialFreq = 1/15;
elem.phase = 0;
elem.orientation = 0;
elem.colour = [1 1 1]';
elem.contrast = 1;
elem.show = false;

% Map the visual element signal through the below function 'makeLayers' and
% assign it to the 'layers' field.  When any of the above parameters takes
% a new value, 'makeLayer' is called, returning the texture layer.
% 'flattenStruct' returns the same texture layer but with all fields
% containing signals replaced by their current value. The 'layers' field
% is loaded by VIS.DRAW
elem.layers = elem.map(@makeLayers).flattenStruct();
end

function layers = makeLayers(newelem)
% make a grating layer of the specified type
switch lower(newelem.grating)
    case {'sinusoid' 'sine' 'sin'}
        [gratingLayer, gratingImg] = vis.sinusoidLayer(newelem.azimuth,...
            newelem.spatialFreq, newelem.phase, newelem.orientation);
        gratingLayer.textureId = 'sinusoidGrating';
    case {'squarewave' 'square' 'sq'}
        [gratingLayer, gratingImg] = vis.squareWaveLayer(newelem.azimuth,...
            newelem.spatialFreq, newelem.phase, newelem.orientation);
        gratingLayer.textureId = 'squareWaveGrating';
    otherwise
        error('grating:error', 'Invalid grating type ''%s''', newelem.grating);
end
% Convert the texture image to the correct format - a column vector of
% RGBA values between 0 and 255. Output the image size to the
% 'rgbaSize' field
[gratingLayer.rgba, gratingLayer.rgbaSize] = vis.rgba(gratingImg, 1);
gratingLayer.blending = 'destination';
% Scale the min and max colours in each channel by the contrast
l = 0.5 - 0.5*newelem.contrast;
h = 0.5 + 0.5*newelem.contrast;
gratingLayer.minColour = l.*[newelem.colour(:); 0];
gratingLayer.maxColour = h.*[newelem.colour(:); 1];
gratingLayer.show = newelem.show;

% make a stencil layer using a window of the specified type
if ~strcmpi(newelem.window, 'none')
    switch lower(newelem.window)
        case {'gaussian' 'gauss'}
            [winLayer, winImg] = vis.gaussianLayer(...
                [newelem.azimuth; newelem.altitude], newelem.sigma);
            winLayer.textureId = 'gaussianStencil';
        case {'square','sq'}
            [winLayer, winImg] = vis.rectLayer(...
                [newelem.azimuth; newelem.altitude],...
                newelem.sigma, 0);
            winLayer.textureId = 'square';
        otherwise
            error('window:error', 'Invalid window type ''%s''', newelem.window);
    end
    [winLayer.rgba, winLayer.rgbaSize] = vis.rgba(0, winImg);
    winLayer.blending = 'none';
    % Hold the RGBA values fixed at 0 as we only care about the alpha channel
    winLayer.colourMask = [false false false true];
    winLayer.show = newelem.show;
else % no window
    winLayer = [];
end

% The window layer is rendered first like a stencil
layers = [winLayer, gratingLayer];
end
