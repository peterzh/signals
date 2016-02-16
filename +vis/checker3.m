function elem = checker3(t)
%vis.checker A grid of rectangles
%   Detailed explanation goes here

elem = t.Node.Net.subscriptableOrigin('checker');

% defRectSize = [10 10];
% make initial layer to be replicated and configured for each square
patternLayer = vis.emptyLayer();
patternLayer.textureId = sprintf('~checker%i', randi(2^32));
patternLayer.isPeriodic = false;
patternLayer.interpolation = 'nearest';
patternLayer.blending = 'destination';

maskTemplate = vis.emptyLayer();
maskTemplate.isPeriodic = false;
maskTemplate.interpolation = 'nearest';
maskTemplate.show = true;
maskTemplate.colourMask = [false false false true];

maskTemplate.textureId = 'checkerMaskPixel';
[maskTemplate.rgba, maskTemplate.rgbaSize] = vis.rgba(0, 0);
maskTemplate.blending = '1-source';

stencilTemplate = maskTemplate;
stencilTemplate.textureId = 'checkerStencilPixel';
[stencilTemplate.rgba, stencilTemplate.rgbaSize] = vis.rgba(1, 1);
stencilTemplate.blending = 'none';

% elem.layers = elem.map(@removeLayers).flattenStruct().map(@makeLayers);

nRowsByCols = elem.pattern.flatten().map(@size).skipRepeats();
aziRange = elem.azimuthRange.flatten();
altRange = elem.altitudeRange.flatten();
sizeFrac = elem.rectSizeFrac.flatten();
gridMaskLayers = mapn(nRowsByCols, aziRange, altRange, sizeFrac, ...
  maskTemplate, stencilTemplate, @gridMask);

% elem.layers = gridMaskLayers;

checkerLayer = scan(elem.pattern.flatten(), @updatePattern,...
                   elem.colour.flatten(), @updateColour,...
                   elem.azimuthRange.flatten(), @updateAzi,...
                   elem.altitudeRange.flatten(), @updateAlt,...
                   elem.show.flatten(), @updateShow,...
                   patternLayer); % initial value
elem.layers = [gridMaskLayers checkerLayer];
elem.azimuthRange =  [-90 90];
elem.altitudeRange = [-30 30];
elem.rectSizeFrac = [0.5 0.5]; % horizontal and vertical size of each rectangle
elem.pattern = [
   1 -1  1 -1
  -1  0  0  0 
   1  0  0  0
  -1  1 -1  1];
 elem.show = true;
end
%% helper functions
function layer = updatePattern(layer, pattern)
[layer.rgba, layer.rgbaSize] = vis.rgbaFromUint8(...
  uint8(127.5*(1 + pattern)), uint8(abs(255*pattern)));
end

function layer = updateColour(layer, colour)
layer.maxColour = [colour 1];
end

function layer = updateAzi(layer, aziRange)
layer.size(1) = abs(diff(aziRange));
layer.texOffset(1) = mean(aziRange);
end

function layer = updateAlt(layer, altRange)
layer.size(2) = abs(diff(altRange));
layer.texOffset(2) = mean(altRange);
end

function layer = updateShow(layer, show)
layer.show = show;
end

function layers = gridMask(nRowsByCols, aziRange, altRange, sizeFrac, mask, stencil)
gridDims = [abs(diff(aziRange)) abs(diff(altRange))];
cellSize = gridDims./flip(nRowsByCols);
nCols = nRowsByCols(2) + 1;
nRows = nRowsByCols(1) + 1;
midAzi = mean(aziRange);
midAlt = mean(altRange);
%% base layer
stencil.texOffset = [midAzi midAlt];
stencil.size = gridDims;
%% make layers for vertical lines
if nCols > 1
  azi = linspace(aziRange(1), aziRange(2), nCols);
else
  azi = midAzi;
end
collayers = repmat(mask, 1, nCols);
for vi = 1:nCols
  collayers(vi).texOffset = [azi(vi) midAlt];
end
[collayers.size] = deal([(1 - sizeFrac(1))*cellSize(1) gridDims(2)]);
%% make layers for horizontal lines
if nRows > 1
  alt = linspace(altRange(1), altRange(2), nRows);
else
  alt = midAlt;
end
rowlayers = repmat(mask, 1, nRows);
for hi = 1:nRows
  rowlayers(hi).texOffset = [midAzi alt(hi)];
end
[rowlayers.size] = deal([gridDims(1) (1 - sizeFrac(2))*cellSize(2)]);
%% combine
layers = [stencil collayers rowlayers];
end