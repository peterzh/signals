function Visualizor()
f = figure;
net = gca();
c = uicontextmenu(f);
% Create a new component and assign the uicontextmenu to it
b = uicontrol(f,'UIContextMenu',c);
% Create a child menu for the uicontextmenu
m = uimenu('Parent',c,'Label','Add Node','MenuSelectedFcn', @(~,~)addNode);

level = 0;

inputNodes = [];
nodes = [];
eventNodes = [];

inputNodes(1) = addNode('t');

    function node = addNode(name, next)
        if nargin > 1; level = next; end
        node = scatter(net, 1, level, 4000, 'o', 'LineWidth', 2, 'MarkerEdgeColor', 'r');
        node.CreateFcn = '';
        node.DeleteFcn = '@deleteNode';
        node.DisplayName = name;
        node.PickableParts = 'all';
    end

    function node = deleteNode(src, evt)
        % pass
    end
end