classdef Signals_perftest2 < matlab.perftest.TestCase
% Runs performance tests for Signals
%
% Performs benchmarking for various operations on signals: 
% nops, assignment ops, logical ops, scalar arithmetic ops, listener ops,
% 'map', 'scan', subscriptable signal ops (via 'test_ops' method)
%
% And performs benchmarking for propogations through networks of various 
% sizes (from 30 nodes to 1000 nodes) (via 'test_props' method)
%   
% Example - display the mean measured time for running each test:
%   results = runperf('Signals_perftest2.m');
%   fullTableResults = vertcat(results.Samples);
%   meanTimeByTestTable = varfun(@mean, fullTableResults,...
%     'InputVariables', 'MeasuredTime', 'GroupingVariables', 'Name')
  
  properties
    Net % Signals network ('sig.net' object)
    A % origin signal ('sig.node.OriginSignal' object)
    B % origin signal ('sig.node.OriginSignal' object)
    Reps = 1000 % number of test repetitions 
  end
  
  properties (TestParameter)
    Ops = {@nop, @post, @gt, @ge, @lt, @le, @eq,... 
        @plus, @minus, @times, @rdivide, @onValue, @map, @scan, @subscriptable} % functions to test
    NumNodes = {30 100 500 1000}; % number of nodes in the network, not counting A & B
     OnlyBasicOps = {1 0}; % flag for whether or not to only use logical/scalar ops in the network tested in 'test_networkOps'
    BasicOps = {@gt, @ge, @lt, @le, @eq,...
        @plus, @minus, @times, @rdivide} % logical/arithmetical subset of functions to test
  end
  
  methods (TestClassSetup)
    
    function createNetwork(testCase)
      % creates the signals network in which we will run the tests
      testCase.Net = sig.Net;
      testCase.A = testCase.Net.origin('A');
      testCase.B = testCase.Net.origin('B');
    end
    
  end
    
  methods (Test)
    
    function test_singleOps(testCase, Ops)
      % benchmarks operations on a single signal without propogations
      
      % set-up op to test
      switch func2str(Ops)
        % logical and scalar ops
        case {'gt', 'ge', 'lt', 'le', 'eq', 'plus', 'minus', 'times', 'rdivide'}
          c = feval(Ops, testCase.A, testCase.B); %#ok<*NASGU>
          post(testCase.B, 2);
        % listener ('onValue') & 'map' ops
        case {'onValue', 'map'}
          f = @plus;
          c = feval(Ops, testCase.A, @(x) f(1,x));
          while (testCase.keepMeasuring)
            post(testCase.A, 1);
          end
        % 'scan'
        case {'scan'}
          f = @plus;
          c = feval(Ops, testCase.A, f, testCase.B);
          post(testCase.B, 0);
          while (testCase.keepMeasuring)
            post(testCase.A, 1);
          end
        % 'subscriptable'
        case {'subscriptable'}
          s = struct('A', 1);
          c = feval(Ops, testCase.A);
          c_A = c.A;
          while (testCase.keepMeasuring)
            post(testCase.A, s);
          end
      end
      
      % test op
      switch func2str(Ops)
        case {'nop', 'post'}
          while (testCase.keepMeasuring)
            for i = 1:testCase.Reps
              feval(Ops, testCase.A, 1);
            end
          end
        case {'gt', 'ge', 'lt', 'le', 'eq', 'plus', 'minus', 'times',...
            'rdivide', 'onValue', 'map', 'scan'}
          while (testCase.keepMeasuring)
            for i = 1:testCase.Reps
              post(testCase.A, 1); % this post will trigger the update of signal 'c', defined above
            end
          end
        case {'subscriptable'}
          while (testCase.keepMeasuring)
            for i = 1:testCase.Reps
              post(testCase.A, s); % this post will trigger the update of signal 'c_A', defined above
            end
          end
      end
      
    end
    
    function test_networkOps(testCase, OnlyBasicOps, NumNodes)
      % benchmarks operations on a signals network upon posting to a signal
      % which updates all other signals in the network
      
      % create an empty array that will grow
      vals = [];
      
      % set-up network to test
      otherSigs = cell(NumNodes,1);
      if OnlyBasicOps % pick operation for signal at random amongst 'testCase.BasicOps'
        for i = 1:NumNodes
          op = randsample(testCase.BasicOps, 1);
          op = op{1};
          otherSigs{i} = feval(op, testCase.A, testCase.B);
        end
      else % pick operation for signal at random amongst 'testCase.Ops'
        for i = 1:NumNodes
          op = randsample(testCase.Ops, 1);
          op = op{1};
          switch func2str(op)
            % for ops that do not create a new signal upon posting 1 to
            % 'testCase.A', change op to '@gt'
            case {'nop', 'post', 'subscriptable', 'onValue'}
              op = @gt;
              otherSigs{i} = feval(op, testCase.A, 1);
            case {'gt', 'ge', 'lt', 'le', 'eq', 'plus', 'minus', 'times', 'rdivide'}
              otherSigs{i} = feval(op, testCase.A, testCase.B);
            case {'map'}
              otherSigs{i} = feval(op, testCase.A, @(x) plus(1,x));
            case {'scan'}
              otherSigs{i} = feval(op, testCase.A, @plus, testCase.B);
          end
        end
        % create a listener that calls a function which grows an array each
        % time the signal updates
        % @fixme: currently this causes a MATLAB crash, presumably b/c
        % 'store' function is called repeatedly too quickly
        % growArrayListener = onValue(testCase.A, @store);
      end
      
      %networkInfo(testCase.Net); % displays the number of active nodes in the network
      
      % test network (i.e. propogations through the network)
      post(testCase.B, 2);
      while (testCase.keepMeasuring)
          post(testCase.A, 1);
      end
      
      % grow an array every time 'map' or 'onValue' gets called 
      function store(x)
        vals = [vals x];
      end
    end
    
  end
  
end