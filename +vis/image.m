function elem = image(t, window)
%VIS.IMAGE Returns layers for presenting an image
%   Detailed explanation goes here

if nargin < 3 || isempty(window)
  window = 'none';
end

elem = t.Node.Net.subscriptableOrigin('cat');
elem.azimuth = 0;
elem.altitude = 0;
elem.dims = [50,50];
elem.orientation = 0;
elem.sourceImage = false;
elem.colour = [1 1 1];
elem.rescale = false;
elem.show = false;
elem.isPeriodic = false;
elem.sigma = [5,5];
elem.window = window;
elem.layers = elem.map(@makeLayers).flattenStruct();

  function layers = makeLayers(newelem)
    clear elem t; % eliminate references to unsed outer variables
    %% make a grating layer of the specified type
    imgLayer = vis.emptyLayer();
    imgLayer.texOffset = [newelem.azimuth, newelem.altitude];
    imgLayer.pos = [newelem.azimuth, newelem.altitude];
    imgLayer.texAngle = newelem.orientation;
    imgLayer.size = newelem.dims;
    imgLayer.isPeriodic = newelem.isPeriodic;
    imgLayer.textureId = 'image';
    %     imgLayer.blending = 'destination';
    imgLayer.interpolation = 'linear';
    imgLayer.maxColour = [newelem.colour 1];
    imgLayer.colourMask = [true true true true];
    
    if isobject(newelem.sourceImage)
      if newelem.rescale
        imgLayer.rgba = map(newelem.sourceImage,...
          @(img)vis.rgba(rescale(img),1));
      else
        imgLayer.rgba = map(newelem.sourceImage, @(img)vis.rgba(img,1));
      end
      imgLayer.rgbaSize = map(newelem.sourceImage,...
        @(img)[size(img,2), size(img,1)]);
    else
      if newelem.rescale
        [imgLayer.rgba, imgLayer.rgbaSize] = ...
          vis.rgba(rescale(newelem.sourceImage),1);
      else
        [imgLayer.rgba, imgLayer.rgbaSize] = ...
          vis.rgba(newelem.sourceImage,1);
      end
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
    %
    layers = [winLayer, imgLayer];
  end
  function img = rescale(img)
    img = max(img,-1); img = min(img, 1);
    img = (img*128+128);
  end
end