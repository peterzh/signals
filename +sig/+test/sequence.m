function s = sequence(seq, interval, delay)
  persistent net schedule nodes n
  if nargin < 3; delay = 2; end
  if isempty(net) 
    net = sig.Net;
    net.Debug = 'on';
  end
  if isempty(nodes)
    nodes = net.origin('nodes'); 
    nNodes = nodes.scan(@plus, 0);
    n = then(nNodes < 1, true);
  end
  update = net.origin('indexer');
  seqSig = net.origin('seq'); seqSig.post(seq);
  idx = update.scan(@plus, 0);
  idx = idx.keepWhen(idx <= length(seq));
  s = seqSig(idx);
  s.Listeners = TidyHandle(@()nodes.post(-1));
  s.Name = 'sequence';
  tmr = timer('Name', 'Sequence timer', ...
    'ExecutionMode', 'fixedRate', ...
    'Period', interval, ...
    'StartDelay', delay, ...
    'TimerFcn', @(~,~)update.post(true),...
    'StopFcn', @(~,~)cleanup);
  if isempty(schedule) || ~isvalid(schedule)
    schedule = timer('Name', 'Schedule timer', ...
      'ExecutionMode', 'fixedDelay', ...
      'Period', 0.05, ...
      'TimerFcn', @(~,~)net.runSchedule, ...
      'StopFcn', @(src,~)delete(src));
  elseif strcmp(schedule.running, 'off')
    start(schedule)
    net.Listeners = n.onValue(@(~)stop(schedule));
  end
  terminate = at(-1, idx == length(seq));
  h = terminate.delay(1).onValue(@(~)stop(tmr));
  start(tmr)
  nodes.post(1);
  
  function cleanup()
    if isvalid(tmr); delete(tmr); end
    delete(h)
    disp('deleting')
  end
end
      