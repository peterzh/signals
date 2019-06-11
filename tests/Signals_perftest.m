classdef Signals_perftest < matlab.perftest.TestCase
% Runs performance tests for Signals
%
% Performs benchmarking for various operations on signals: 
% nops, assignment ops, logical ops, scalar arithmetic ops, listener ops,
% and signal methods: `map`, `scan`, `identity`, `subscriptable`, etc...
% (via `test_mainOps` and `test_signalsOps` methods)
%
% And performs benchmarking for propogations through each signal in 
% networks of various widths and depths (30 to 1000 nodes spread across 2
% to 20 layers) (via `test_networkOps` method) (*Note: for reference, the 
% `docs\examples\advancedChoiceWorld` exp def has 338 nodes over 10 layers)
%
% In this class, the 'Net' property is a Signals network, in which the 
% 'A' & 'B' properties are treated as "input layer" signals from which all 
% other signals are defined.
%   
% Example - display the mean measured time for running each test:
%   results = runperf('Signals_perftest2.m');
%   fullTableResults = vertcat(results.Samples);
%   meanTimeByTestTable = varfun(@mean, fullTableResults,...
%     'InputVariables', 'MeasuredTime', 'GroupingVariables', 'Name')
  
  properties
    Net % Signals network ('sig.Net' object)
    A % origin signal ('sig.node.OriginSignal' object)
    B % origin signal ('sig.node.OriginSignal' object)
    Reps = 1000 % number of test repetitions 
  end
  
  properties (TestParameter)
    % main operations to test (whose results are posted in the paper)
    MainOps = {@nop, @post, @gt, @ge, @lt, @le, @eq,... 
      @plus, @minus, @times, @rdivide, @onValue, @identity, @map, @scan,... 
      @subscriptable}
    % logical/arithmetical subset of operations to test (operations which
    % are computed directly in compiled mexnet)
    BasicOps = {@gt, @ge, @lt, @le, @eq,...
      @plus, @minus, @times, @rdivide}
    % sig.node.Signal method operations which have transfer functions 
    % (those not included are redundant on these included)
    SignalsOps = {@at, @keepWhen, @mapn, @cond, @selectFrom, @indexOfFirst,... 
      @merge, @to, @skipRepeats, @delay, @flattenStruct, @flatten, @log,...
      @subsref}
    % number of total nodes in the network
    NumNodes = {30 120 350 1000}
    % number of layers of nodes in the network after "input layer"
    Depth = {2 5 10 20}
    % flag for whether or not to only use logical/scalar ops
    OnlyBasicOps = {1 0};
  end
  
  methods (TestMethodSetup)
    
    function createNetwork(testCase)
      % creates the signals network in which we will run the tests
      testCase.Net = sig.Net;
      testCase.A = testCase.Net.origin('A');
      testCase.B = testCase.Net.origin('B');
    end
    
  end
    
  methods (Test)
    
    function test_mainOps(testCase, MainOps)
      % benchmarks operations on a single signal without propogations
      
      % set-up op to test
      switch func2str(MainOps)
        % logical and scalar ops
        case {'gt', 'ge', 'lt', 'le', 'eq', 'plus', 'minus', 'times', 'rdivide'}
          c = feval(MainOps, testCase.A, testCase.B); %#ok<*NASGU>
          post(testCase.B, 2);
        % 'identity'
        case {'identity'}
          c = feval(MainOps, testCase.A);
        % listener ('onValue') & 'map' ops
        case {'onValue', 'map'}
          f = @plus;
          c = feval(MainOps, testCase.A, @(x) f(1,x));
        % 'scan'
        case {'scan'}
          f = @plus;
          c = feval(MainOps, testCase.A, f, testCase.B);
          post(testCase.B, 0);
        % 'subscriptable'
        case {'subscriptable'}
          s = struct('A', 1);
          c = feval(MainOps, testCase.A);
          c_A = c.A;
      end
      
      % test op
      switch func2str(MainOps)
        case {'nop', 'post'}
          while (testCase.keepMeasuring)
            for i = 1:testCase.Reps
              feval(MainOps, testCase.A, 1);
            end
          end
        case {'gt', 'ge', 'lt', 'le', 'eq', 'plus', 'minus', 'times',...
            'rdivide', 'onValue', 'map', 'scan', 'identity'}
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
    
    function test_signalsOps(testCase, SignalsOps)
      % @todo: create this test modeled off the above
    end
    
    function test_networkOps(testCase, OnlyBasicOps, NumNodes, Depth)
      % benchmarks operations on a Signals network upon posting to a signal
      % which updates all other signals in the network
      
      % set-up network to test
      sigs = cell(NumNodes); % cell array of all signals to be tested
      sigs{1} = testCase.A;
      sigs{2} = testCase.B;
      
      % number of ops to sample evenly
      numOps = iff(OnlyBasicOps, length(testCase.BasicOps),... 
        length(testCase.MainOps));
      nodeNum = 1; % counter
      
      for node = 3:NumNodes
        if OnlyBasicOps % can't use `iff` here b/c we are returning a function handle
          op = testCase.BasicOps{mod(nodeNum, numOps)+1};
        else
          op = testCase.MainOps{mod(nodeNum, numOps)+1};
        end
        
        % we'll use this to distribute nodes across layers evenly
        parentANode = mod((node-3), Depth) + 1; 
        parentBNode = mod((node-2), Depth) + 1;
        % create new signal from nodes in previous layer
        switch func2str(op)  
          % for ops that do not create a new signal upon posting 1 to
          % 'testCase.A', change op to '@identity'
          case {'nop', 'post', 'subscriptable', 'onValue', 'identity'}
            op = @identity;
            sigs{node} = feval(op, sigs{parentANode});
          case {'gt', 'ge', 'lt', 'le', 'eq', 'plus', 'minus', 'times', 'rdivide'}
            sigs{node} = feval(op, sigs{parentANode}, sigs{parentBNode});
          case {'map'}
            sigs{node} = feval(op, sigs{parentANode}, @identity);
          case {'scan'}
            sigs{node} = feval(op, sigs{parentANode}, @plus, sigs{parentBNode});
        end
        nodeNum = nodeNum + 1;
      end
      
      % create an empty array that will grow
      vals = [];
      
      % create a listener that calls a function which grows an array each
      % time the signal updates
      
      % @fixme: currently the code below causes a MATLAB crash,
      % presumably b/c 'store' function is called repeatedly too quickly
      %growArrayListener = onValue(testCase.A, @store);
      
      
      % test network (i.e. propogations through the network)
      post(testCase.B, 2);
      while (testCase.keepMeasuring)
          post(testCase.A, 1);
      end
      
      % grow an array every time `A` posts 
      function store(x)
        vals = [vals x];
      end
    end
    
  end
  
end