function elem = checker2(t)
%vis.checker A grid of rectangles
%   Detailed explanation goes here

elem = t.Node.Net.subscriptableOrigin('checker');

defRectSize = [10 10];
% make initial layer to be replicated and configured for each square
[initLayer, img] = vis.rectLayer([0 0], defRectSize, 0);
[initLayer.rgba, initLayer.rgbaSize] = vis.rgba(1, img);
initLayer.textureId = 'square';
% elem.layers = elem.map(@removeLayers).flattenStruct().map(@makeLayers);

show = elem.show.flatten();
gridSize = show.map(@size);
aziRange = elem.azimuthRange.flatten();
altRange = elem.altitudeRange.flatten();
elem.layers = scan(show, @updateShow,...
                   elem.colour.flatten(), @updateColour,...
                   aziRange, @updateAzi,...
                   altRange, @updateAlt,...
                   initLayer,... % initial value
                   'pars', aziRange, altRange, gridSize);
elem.azimuthRange = [-90 90];
elem.altitudeRange = [-45 45];
elem.rectSize = [10 10]; % horizontal and vertical size of each rectangle
elem.show = false(3, 3);
end
%% helper functions
function layers = updateShow(layers, show, aziRange, altRange, ~)
if numel(layers) ~= numel(show) % num of layers need to change
  layers = repmat(layers(1), 1, numel(show)); % replicate one of them
  newCentres = num2cell(gridCentres(aziRange, altRange, size(show)), 2);
  [layers.texOffset] = newCentres{:};
end
show = num2cell(show);
[layers.show] = show{:};
end

function layers = updateColour(layers, colour, ~, ~, ~)
[layers.maxColour] = deal([colour 1]);
end

function layers = updateAzi(layers, aziRange, ~, altRange, gridSize)
newCentres = num2cell(gridCentres(aziRange, altRange, gridSize), 2);
[layers.texOffset] = newCentres{:};
end

function layers = updateAlt(layers, altRange, aziRange, ~, gridSize)
newCentres = num2cell(gridCentres(aziRange, altRange, gridSize), 2);
[layers.texOffset] = newCentres{:};
end

function centres = gridCentres(aziRange, altRange, sz)
azi = linspace(min(aziRange), max(aziRange), sz(2));
alt = linspace(min(altRange), max(altRange), sz(1));
[cenAlt, cenAzi] = ndgrid(alt, azi);
centres = [cenAzi(:) cenAlt(:)];
end