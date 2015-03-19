classdef StructRef < handle
  %UNTITLED2 Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Name = ''
  end

  properties (SetAccess = protected)
    Entries = struct('test', 1:3)
    EntryNames = {};
  end
  
  methods (Sealed)
    function A = subsasgn(this, s, varargin)
      newentry = false;
      if strcmp(s(1).type, '.') && ~any(strcmp(this.EntryNames, s(1).subs))
        newentry = true;
        newentryname = s(1).subs;
      end
      this.Entries = builtin('subsasgn', this.Entries, s, varargin{:});
      A = this;
      if newentry
        this.EntryNames = [this.EntryNames {newentryname}];
        this.Entries.(newentryname) = entryAdded(this, newentryname, this.Entries.(newentryname));
      end
    end
    
    function [varargout] = subsref(this, s)
      [varargout{1:nargout}] = subsref(this.Entries, s);
    end
  end

  methods
    function n = fieldnames(this)
      n = this.EntryNames';
    end
    
    function tf = isfield(this, varargin)
      tf = isfield(this.Entries, varargin{:});
    end
    
    function value = entryAdded(this, name, value)
%       fprintf('entry %s:%s added\n', name, toStr(value));
    end
  end
end