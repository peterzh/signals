classdef OriginStructSignal < sig.node.StructSignal & ...
    sig.node.OriginSignal
  
  %sig.FieldSubscriptableOriginSignal Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function this = OriginStructSignal(node, varargin)
      this = this@sig.node.StructSignal(node, varargin{:});
      this = this@sig.node.OriginSignal(node);
    end
    
    function a = subsasgn(a, s, b)
      % todo: this function is currently hacky
      if isa(a, 'sig.node.OriginStructSignal')
        if s(1).type == '.' && any(strcmp(s(1).subs, a.Reserved))
          a = builtin('subsasgn', a, s, b);
        else
          assert(numel(s) == 1, 'todo');
          newValue = subsasgn(a.Node.CurrValue, s(1), b);
          post(a, newValue);
        end
      else
        a = builtin('subsasgn', a, s, b);
      end
    end
    %
    %     function [varargout] = subsref(a, s)
    %       [varargout{1:nargout}] = subsref@sig.node.SubscriptableSignal(a, s);
    %     end
  end
  
end

