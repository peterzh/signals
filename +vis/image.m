function elem = image(t, sourceImage, alpha)
% VIS.IMAGE Returns visual element for image presentation in Signals
%  Produces a visual element for parameterizing the presentation of an
%  image
%
%  Inputs:
%    t - any signal with which to derive the network ID.  By convetion we
%      use the t signal
%    sourceImage - either an image, path to an image or a Signal
%    alpha - the alpha value(s) for the image.  Maybe a single value or
%      array the size of sourceImage.  If no alpha value is provided and
%      sourceImage is a char
%
%  Outputs:
%    elem - a subscriptable signal containing paramter fields for the
%      stimulus along with the processed texture layers.  Any parameter may
%      be a signal.
%
%  Stimulus (elem) parameters:
%    window - char array defining the type of windowing applied.  Options
%      are 'none' (default) or 'gaussian'
%    dims - the dimentions of the image in visual degrees.  Must be an 
%      array of the form [width height]. Default [10 10]
%    azimuth - the position of the shape in the azimuth (position of the
%      centre pixel in visual degrees).  Default 0
%    altitude - the position of the shape in the altitude. Default 0
%    sigma - if window is Gaussian, the size of the window in visual
%      degrees.  Must be an array of the form [width height].
%      Default [10 10]
%    orientation - the orientation of the grating in degrees. Default 0
%    contrast - the normalized contrast of the grating (between 0 and 1).
%      Default 1
%    repeat - boolean to indicate whether to tile the image accross the
%      entire visual field.  Default false
%    show - a logical indicating whether or not the stimulus is visible.
%      Default false
%
%  NB: If loading multiple visual elements with different image paths
%  ensure that the images themselves have unique filenames.
%
%  TODO Add contrast parameter
%  @body Add parameter to set overall contrast of the image, effectively
%  scaling it?  Would need to know the range of the source image...
%
%  TODO Add colour parameter
%  @body Add parameter to set the intensity of each channel. How would this
%  work for none-greyscale source images?
%
%  See Also VIS.GRATING, VIS.CHECKER6, VIS.GRID

% Add a new subscriptable origin signal to the same network as the input
% signal, t, and use this to store the stimulus texture layer and
% parameters
elem = t.Node.Net.subscriptableOrigin('image');
elem.azimuth = 0;
elem.altitude = 0;
elem.dims = [50,50];
elem.orientation = 0;
elem.repeat = false;
elem.sourceImage = [];
elem.alpha = 1;
elem.show = false;
elem.window = 'none';
elem.sigma = [5,5];

% Map the visual element signal through the below function 'makeLayer' and
% assign it to the layers field.  When any of the above parameters takes a
% new value, makeLayer is called, returning the texture layer.
% flattenStruct returns the same texture layer but with all fields
% containing signals replaced by their current value.  It is this field
% that is loaded by VIS.DRAW
elem.layers = elem.map(@makeLayers).flattenStruct();

% Deal with texture naming
persistent imageNum
name = sprintf('image%i',imageNum);
% If source image is given as an input, update the visual element
if nargin > 1
  % If the image is a char array, assume it is a path and attempt to load
  % the image.  If there's a transparency layer, use it.
  if isa(sourceImage, 'char')
    [~,filename,~] = fileparts(sourceImage);
    name = sprintf('%s',filename); 
    [elem.sourceImage, ~, srcAlpha] = imread(sourceImage);
    if ~isempty(srcAlpha); elem.alpha = srcAlpha; end
  elseif isobject(sourceImage) % Assume Signal
    name = sourceImage.Name;
    elem.sourceImage = sourceImage;
  else
    elem.sourceImage = sourceImage;
  end
end
% If input alpha is none-empty, overwrite whatever was returned by imread.
if nargin > 2 && ~isempty(alpha); elem.alpha = alpha; end
imageNum = iff(isempty(imageNum), 1, imageNum + 1);
elem.Name = name;

  function layers = makeLayers(newelem)
    %% make an image layer
    imgLayer = vis.emptyLayer();
    % If sourceImage field is empty, return an empty layer
    if isempty(newelem.sourceImage)
      layers = imgLayer;
      return
    end
    imgLayer.texOffset = [newelem.azimuth, newelem.altitude];
    imgLayer.texAngle = newelem.orientation;
    imgLayer.size = newelem.dims;
    imgLayer.isPeriodic = newelem.repeat;
    imgLayer.interpolation = 'linear';
    
    if isobject(newelem.sourceImage)
      % FIXME Make vis.rgba a Signal method or define new image subclass? 
      imgLayer.textureId = ['~',name];
      imgLayer.rgba = map(newelem.sourceImage, @(img)vis.rgba(img,1));
      imgLayer.rgbaSize = map(newelem.sourceImage,...
        @(img)[size(img,2), size(img,1)]);
    else
      imgLayer.textureId = name;
      [imgLayer.rgba, imgLayer.rgbaSize] = ...
        vis.rgba(newelem.sourceImage, newelem.alpha);
    end
    imgLayer.show = newelem.show;
    
    %% make a stencil layer using a window of the specified type
    if ~strcmpi(newelem.window, 'none')
      switch lower(newelem.window)
        case {'gaussian' 'gauss'}
          [winLayer, winImg] = vis.gaussianLayer(...
            [newelem.azimuth; newelem.altitude], newelem.sigma);
          winLayer.textureId = 'gaussianStencil';
        otherwise
          error('Invalid window type ''%s''', newelem.window);
      end
      [winLayer.rgba, winLayer.rgbaSize] = vis.rgba(0, winImg);
      winLayer.blending = 'none';
      winLayer.colourMask = [false false false true];
      winLayer.show = newelem.show;
    else % no window
      winLayer = [];
    end
    layers = [winLayer, imgLayer];
  end
end