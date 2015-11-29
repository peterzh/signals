function elem = grid(t)
%VIS.GRATINGELEM Summary of this function goes here
%   Detailed explanation goes here

elem = t.Node.Net.subscriptableOrigin('grid');
elem.azimuths = [-180 -90 0 90 180];
elem.altitudes = [-90 0 90];
elem.thickness = 2;
elem.colour = [102 153 255]/255;
elem.show = false;
elem.layers = elem.map(@makeLayers).flattenStruct();

  function layers = makeLayers(newelem)
    clear elem t; % eliminate references to unsed outer variables
    %% columns
    colsize = [newelem.thickness 180];
    for li = 1:numel(newelem.azimuths)
        [layer, img] = vis.rectLayer(...
          [newelem.azimuths(li); 0],...
          colsize, 0);
        [layer.rgba, layer.rgbaSize] = vis.rgba(1, img);
        layer.textureId = 'square';
        layer.blending = 'source';
        layer.maxColour = [newelem.colour 1];
        layer.show = newelem.show;
        layers(li) = layer;
    end
    %% rows
    rowsize = [360 newelem.thickness];
    for li = 1:numel(newelem.altitudes)
      [layer, img] = vis.rectLayer(...
        [0; newelem.altitudes(li)],...
        rowsize, 0);
      [layer.rgba, layer.rgbaSize] = vis.rgba(1, img);
      layer.textureId = 'square';
      layer.blending = 'source';
      layer.maxColour = [newelem.colour 1];
      layer.show = newelem.show;
      layers(end+1) = layer;
    end
%     switch lower(shape)
%       case {'rectangle' 'rect' 'r'}
%         [layer, img] = vis.rectLayer(...
%           [newelem.azimuth; newelem.altitude],...
%           newelem.size, newelem.orientation);
%         layer.textureId = 'square';
%         layer.blending = 'source';
%       otherwise
%         error('Invalid grating type ''%s''', shape);
%     end
%     layer.maxColour = [newelem.colour 1];
%     [layer.rgba, layer.rgbaSize] = vis.rgba(1, img);
%     layer.show = newelem.show;
  end

end