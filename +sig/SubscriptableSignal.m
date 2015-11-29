classdef SubscriptableSignal < handle & fun.Mappable
  %SIG.SUBSCRIPTABLESIGNAL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (SetAccess = protected)
    Wrapped
    Reserved = {'Name' 'post' 'onValue' 'map' 'map2' 'mapn' 'Wrapped' 'at'...
      'printOnValue' 'sample' 'keepWhen' 'flatten' 'flattenStruct'...
      'CurrValue'}
    Deep = false
  end
  
  properties (Dependent)
    Name
  end
  
  methods
    function this = SubscriptableSignal(wrapped, deep)
      if nargin > 1
        this.Deep = deep;
      end
      this.Wrapped = wrapped;
    end
    
    function list = printOnValue(this, format)
      list = printOnValue(this.Wrapped, format);
    end
    
    function a = subsasgn(a, s, b)
      % todo: this function is currently hacky
      for ii = 1:length(s)
        switch s(ii).type
          case '.'
            if  any(strcmp(s(ii).subs, a.Reserved))
              a.Wrapped = builtin('subsasgn', a.Wrapped, s(ii:end), b);
              return;
            end
          case '()'
          otherwise
            error('todo');
        end
      end
      newValue = subsasgn(a.Wrapped.CurrValue, s(ii), b);
      post(a.Wrapped, newValue);
    end
    
    function [varargout] = subsref(a, s)
      b = a.Wrapped;
      for ii = 1:length(s)
        if strcmp(s(ii).type, '.') && any(strcmp(s(ii).subs, a.Reserved))
          [varargout{1:nargout}] = builtin('subsref', b, s(ii:end));
          return;
        end
        b = singleSubsRefMap(b, s(ii));
      end
      varargout = {b};
    end

    function out = map(this, f, varargin)
      out = map(this.Wrapped, f, varargin{:});
      if this.Deep
        out = sig.SubscriptableSignal(out);
      end
    end
    
    function out = at(this, when)
      out = at(this.Wrapped, when);
      if this.Deep
        out = sig.SubscriptableSignal(out);
      end
    end
    
    function out = map2(this, f, other, varargin)
      if isa(this, 'sig.SubscriptableSignal')
        this = this.Wrapped;
      end
      if isa(other, 'sig.SubscriptableSignal')
        other = other.Wrapped;
      end
      out = map2(this, f, other, varargin{:});
      if this.Deep
        out = sig.SubscriptableSignal(out, true);
      end
    end
    
    function out = mapn(f, this, varargin)
      args = unwrap([{this} varargin]);
      
      out = mapn(this, f, args{:});
      if this.Deep
        out = sig.SubscriptableSignal(out, true);
      end
    end
    
    function out = sample(this, interval)
      args = unwrap({this, interval});
      out = sample(args{:});
      if this.Deep
        out = sig.SubscriptableSignal(out, true);
      end
    end
    
    function out = keepWhen(this, pred)
      args = unwrap({this, pred});
      out = keepWhen(args{:});
      if this.Deep
        out = sig.SubscriptableSignal(out, true);
      end
    end
    
    function post(this, value)
      post(this.Wrapped, value);
    end
    
    function l = onValue(this, f)
      l = onValue(this.Wrapped, f);
    end
  end
  
  methods (Static)
    function things = unwrap(things)
       for ii = 1:numel(things)
        if isa(things{ii}, 'sig.SubscriptableSignal')
          things{ii} = things{ii}.Wrapped;
        end
      end
    end
  end
  
end

