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

lineLayer = vis.emptyLayer();
lineLayer.textureId = sprintf('stencilPixel');
lineLayer.isPeriodic = false;
lineLayer.interpolation = 'nearest';
lineLayer.show = true;
[lineLayer.rgba, lineLayer.rgbaSize] = vis.rgba(1, 1);


% lineLayer.blending = 'none';
% lineLayer.colourMask = [false false false true];

% elem.layers = elem.map(@removeLayers).flattenStruct().map(@makeLayers);

gridSize = elem.pattern.flatten().map(@size).skipRepeats();
aziRange = elem.azimuthRange.flatten();
altRange = elem.altitudeRange.flatten();
lineLayers = mapn(gridSize, aziRange, altRange, lineLayer, @gridMask);

elem.layers = lineLayers;

% elem.layers = scan(elem.pattern.flatten(), @updatePattern,...
%                    elem.colour.flatten(), @updateColour,...
%                    elem.azimuthRange.flatten(), @updateAzi,...
%                    elem.altitudeRange.flatten(), @updateAlt,...
%                    elem.show.flatten(), @updateShow,...
%                    lineLayer); % initial value
                   
elem.azimuthRange = [-60 60];
elem.altitudeRange = [-30 30];
% elem.rectSize = defRectSize; % horizontal and vertical size of each rectangle
elem.pattern = [
   1  0  1
   0 -1  0 
   1  0  1];
 elem.show = true;
end
%% helper functions
function layers = gridMask(gridSize, aziRange, altRange, template)
ncols = gridSize(2) + 1;
nrows = gridSize(1) + 1;
midazi = mean(aziRange);
midalt = mean(altRange);
if ncols > 1
  azi = linspace(aziRange(1), aziRange(2), ncols);
else
  azi = midazi;
end
if nrows > 1
  alt = linspace(altRange(1), altRange(2), nrows);
else
  alt = midalt;
end
collayers = repmat(template, 1, ncols);
for vi = 1:(gridSize(1) + 1)
  collayers(vi).texOffset = [azi(vi) midalt];
end

[collayers.size] = deal([5 abs(diff(aziRange))]);

layers = collayers;

end

% function layers = updatePattern(layers, pattern)
% 
% % [layers.rgba, layers.rgbaSize] = vis.rgbaFromUint8(...
% %   uint8(127.5*(1 + pattern)), uint8(abs(255*pattern)));
% end
% 
% function layer = updateColour(layer, colour)
% layer.maxColour = [colour 1];
% end
% 
% function layers = updateAzi(layers, aziRange)
% % layers.size(1) = abs(diff(aziRange));
% % layers.texOffset(1) = mean(aziRange);
% end
% 
% function layer = updateAlt(layer, altRange)
% % layer.size(2) = abs(diff(altRange));
% % layer.texOffset(2) = mean(altRange);
% end
% 
% function layer = updateShow(layer, show)
% [layers.show] = deal(show);
% end