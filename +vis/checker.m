function elem = checker(t)
%vis.checker A grid of rectangles
%   Detailed explanation goes here

elem = t.Node.Net.subscriptableOrigin('checker');
azis = [0]; % horizontal grid coordinates (defining center of rectangles)
alts = [0]; % vertical grid coordinates
elem.azimuths = azis;
elem.altitudes = alts;
elem.rectSize = [10 10]; % horizontal and vertical size of each rectangle
elem.colour = [1 1 1];
elem.show = false(numel(azis), numel(alts));
% elem.show = map2(elem.azimuths.map(@numel), elem.altitudes.map(@numel), @false);
elem.layers = elem.map(@makeLayers).flattenStruct();
end

function layers = makeLayers(newelem)
clear elem t; % eliminate references to unsed outer variables
fprintf(1, 'checker layers\n')
nAz = numel(newelem.azimuths);
nAl = numel(newelem.altitudes);

for azGrid = 1:nAz
    for alGrid = 1:nAl
        q = (azGrid-1)*nAl+alGrid; % linear index
        [layer, img] = vis.rectLayer(...
            [newelem.azimuths(azGrid); newelem.altitudes(alGrid)],...
            newelem.rectSize, 0);
        [layer.rgba, layer.rgbaSize] = vis.rgba(1, img);
        layer.textureId = 'square';
        layer.blending = 'source';
        layer.maxColour = [newelem.colour 1];
        layer.show = newelem.show(azGrid, alGrid);
        layers(q) = layer;
    end
end
end