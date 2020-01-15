function varargout = create(net)
% TODO add names as input args
% TODO Document sig.test.create
if nargin < 1
  net = sig.Net;
  net.Debug = 'on';
end

varargout = cell(1,nargout);
for i = 1:nargout
  varargout{i} = net.origin(char(i+96));
end