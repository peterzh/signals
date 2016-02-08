function elem = checker2(t)
%vis.checker A grid of rectangles
%   Detailed explanation goes here

elem = t.Node.Net.subscriptableOrigin('checker');
elem.azimuthRange = [-90 90];
elem.altitudeRange = [-45 45];
elem.rectSize = [10 10]; % horizontal and vertical size of each rectangle
elem.colour = [1 1 1];

% elem.show = map2(elem.azimuths.map(@numel), elem.altitudes.map(@numel), @false);
elem.show = false(1);
elem.layers = elem.map(@removeLayers).flattenStruct().map(@makeLayers);
elem.show = false(1);
end

% function layers = showToLayers(show)
% layers = vis.emptyLayer();
% % for azGrid = 1:nAz
% %   for alGrid = 1:nAl
% %     q = (azGrid-1)*nAl+alGrid; % linear index
% %     [layer, img] = vis.rectLayer(...
% %       [newelem.azimuths(azGrid); newelem.altitudes(alGrid)],...
% %       newelem.rectSize, 0);
% %     [layer.rgba, layer.rgbaSize] = vis.rgba(1, img);
% %     layer.textureId = 'square';
% %     layer.blending = 'source';
% %     layer.maxColour = [newelem.colour 1];
% %     layer.show = newelem.show(azGrid, alGrid);
% %     layers(q) = layer;
% %   end
% % end
% end

function elem = removeLayers(elem) % hack for now
elem = rmfield(elem, 'layers');
end

function layers = makeLayers(elem)
% fprintf(1, 'checker layers\n')
% tic
[nAl, nAz] = size(elem.show);
nLayers = numel(elem.show);

if nAl > 1
  al = linspace(elem.altitudeRange(1), elem.altitudeRange(2), nAl);
else
  al = mean(elem.altitudeRange);
end
if nAz > 1
  az = linspace(elem.azimuthRange(1), elem.azimuthRange(2), nAz);
else
  az = mean(elem.azimuthRange);
end
[cenAl, cenAz] = ndgrid(al, az);

[layers, img] = vis.rectLayer([0 0], elem.rectSize, 0);
[layers.rgba, layers.rgbaSize] = vis.rgba(1, img);
layers.textureId = 'square';
layers.maxColour = [elem.colour 1];
layers = repmat(layers, 1, nLayers);

show = num2cell(elem.show);
[layers.show] = show{:};
% pos = num2cell([cenAz(:) cenAl(:)], 2);
% [layers.texOffset] = pos{:};
for li = 1:nLayers
%   layers(li).show = elem.show(li);
  layers(li).texOffset = [cenAz(li) cenAl(li)];
end
% toc
% for azGrid = 1:nAz
%     for alGrid = 1:nAl
%         lidx = lidx + 1;
%         [layer, img] = vis.rectLayer(...
%             [elem.azimuths(azGrid); elem.altitudes(alGrid)], elem.rectSize, 0);
%         [layer.rgba, layer.rgbaSize] = vis.rgba(1, img);
%         layer.textureId = 'square';
%         layer.blending = 'source';
%         layer.maxColour = [elem.colour 1];
%         layer.show = elem.show(azGrid, alGrid);
%         layers(q) = layer;
%     end
% end
end