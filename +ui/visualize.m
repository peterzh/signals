n = nodeInfo(x,y);
[~, ia] = unique([n.Id]);
n = n(ia);
figure;
ax = gca();
nodes = matlab.graphics.chart.primitive.Scatter.empty(length(n),0);

level = [0 2 1 -1 0 2 1 0.5 2 1];
for i = 1:length(n)
  hold on
  nodes(i) = scatter(ax, level(i), n(i).Id, 4000, 'o', 'LineWidth', 2, 'MarkerEdgeColor', 'r');
  nodes(i).DisplayName = n(i).Name;
  text(level(i), n(i).Id, n(i).Name)
  if ~isempty(n(i).Inputs)
    for l = n(i).Inputs
      line([level(i) level(find([n.Id]==l,1))], [n(i).Id, l])
    end
  end
end