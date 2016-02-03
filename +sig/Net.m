classdef Net < handle
  %sig.Net A network that can contain sig.node.Node's.
  %   A network that contains and manages sig.node.Node's.
  
  properties (Transient)
    Schedule
    Listeners
  end
  
  properties (SetAccess = private, Transient)
    Id
  end
  
  events
    Deleting
  end
  
  methods
    function this = Net(size)
      if nargin < 1
        size = 4000;
      end
      this.Id = createNetwork(size);
      this.Schedule = struct('nodeid', {}, 'value', {}, 'when', {});
    end
    
    function runSchedule(this)
      if numel(this.Schedule) > 0
        % slice out due tasks
        dueIdx = [this.Schedule.when] < GetSecs;
        dueTasks = this.Schedule(dueIdx);
        this.Schedule(dueIdx) = [];
        % work through them
        for ti = 1:numel(dueTasks)
          dt = GetSecs - dueTasks(ti).when;
          affectedIdxs = submit(this.Id, dueTasks(ti).nodeid, dueTasks(ti).value);
          changed = applyNodes(this.Id, affectedIdxs);
        end
      end
    end
    
    function s = origin(this, name)
      s = sig.node.OriginSignal(rootNode(this, name));
    end
    
    function s = subscriptableOrigin(this, name)
      s = sig.node.SubscriptableOriginSignal(rootNode(this, name));
    end
    
    function s = fromUIEvent(this, uihandle, callback)
      if nargin < 3
        callback = 'Callback';
      end
      name = sprintf('%s@%sEvents', get(uihandle, 'Type'), callback);
      s = sig.node.SubscriptableOriginSignal(rootNode(this, name));
      set(uihandle, callback, @(src,evt)post(s, evt));
    end
    
    function n = rootNode(this, name)
      n = sig.node.Node(this);
      if nargin < 2
        n.Name = sprintf('n%i', n.Id);
      else
        n.Name = name;
      end
      n.FormatSpec = n.Name;
    end
    
    function delete(this)
      disp('**net.delete**');
      if ~isempty(this.Id)
        notify(this, 'Deleting');
        deleteNetwork(this.Id);
      end
    end
  end
  
  methods (Access = protected)
%     function mexNetworkDeleted(this)
%       fprintf('network #%i''s storage deleted\n', this.Id);
%       this.Id = [];
%     end
  end
  
end