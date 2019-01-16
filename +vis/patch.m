function elem = patch(t, shape)
%VIS.GRATINGELEM Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2 || isempty(shape)
  shape = 'rectangle';
end

elem = t.Node.Net.subscriptableOrigin('patch');
elem.azimuth = 0;
elem.altitude = 0;
elem.dims = [10 10];
elem.orientation = 0;
elem.colour = [1 1 1];
elem.show = false;
elem.layers = elem.map(@makeLayer).flattenStruct();

  function layer = makeLayer(newelem)
    clear elem t; % eliminate references to unsed outer variables
    %% make a grating layer of the specified type
    switch lower(shape)
      case {'rectangle' 'rect' 'r'}
        [layer, img] = vis.rectLayer(...
          [newelem.azimuth; newelem.altitude],...
          newelem.dims, newelem.orientation);
        layer.textureId = 'square';
      case {'circle', 'circ'}
        [layer, img] = vis.circLayer(...
          [newelem.azimuth; newelem.altitude],...
          newelem.dims, newelem.orientation);
        layer.textureId = 'circle';
      case {'plus', 'cross'}
        [layer, img] = vis.crossLayer(...
          [newelem.azimuth; newelem.altitude],...
          newelem.dims, newelem.orientation);
        layer.textureId = 'cross';
      otherwise
        error('Invalid grating type ''%s''', shape);
    end
    layer.blending = 'source';
    layer.maxColour = [newelem.colour 1];
    [layer.rgba, layer.rgbaSize] = vis.rgba(1, img);
    layer.show = newelem.show;
  end

end