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
    MexOps % operations which are run directly in compiled mexnet
  end
  
  properties (TestParameter)
    % main operations to test (whose results are posted in the paper)
    MainOps = {@post, @gt, @ge, @lt, @le, @eq, @plus, @minus, @times, ... 
      @rdivide, @map, @scan, @subscriptable, @onValue}
    % logical/arithmetical subset of operations to test
    BasicOps = {@gt, @ge, @lt, @le, @eq, @plus, @minus, @times, @rdivide}
    %those operations which are run directly in compiled mexnet
    mexOpKeys = num2cell([1:6 10:14 30 40])
    % sig.node.Signal method operations which have transfer functions 
    % (those not included are redundant on these included)
    SignalsOps = {@at, @keepWhen, @mapn, @cond, @selectFrom, @indexOfFirst,... 
      @merge, @to, @skipRepeats, @delay, @identity, @flattenStruct, @flatten, @log,...
      @subsref}
    % number of total nodes in the network
    NumNodes = {30 120 350 1000}
    % number of layers of nodes in the network
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
      
      mexOpVals = {@plus, @minus, @times, @mtimes, @rdivide, @mrdrivide,...
        @gt, @ge, @lt, @le, @eq, @numel, @flattenStruct};
      testCase.MexOps = containers.Map(testCase.mexOpKeys, mexOpVals);
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
        % listener ('onValue') & 'map' ops
        case {'onValue', 'map'}
          f = @identity;
          c = feval(MainOps, testCase.A, f);
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
        case {'post'}
          while (testCase.keepMeasuring)
            for i = 1:testCase.Reps
              feval(MainOps, testCase.A, 1);
            end
          end
        case {'subscriptable'}
          while (testCase.keepMeasuring)
            for i = 1:testCase.Reps
              post(testCase.A, s); % this post will trigger the update of signal 'c_A', defined above
            end
          end  
        otherwise
          while (testCase.keepMeasuring)
            for i = 1:testCase.Reps
              post(testCase.A, 1); % this post will trigger the update of signal 'c', defined above
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
        if mod((node-3), Depth) == 0
          parentNode = 2;
        else
          parentNode = node - 1;
        end
        switch func2str(op)  
          % for ops that do not create a new signal upon posting 1 to
          % 'testCase.A', change op to '@gt'
          case {'post', 'subscriptable', 'onValue'}
            op = @gt;
            sigs{node} = feval(op, sigs{parentNode}, sigs{1});
          case {'gt', 'ge', 'lt', 'le', 'eq', 'plus', 'minus', 'times', 'rdivide'}
            sigs{node} = feval(op, sigs{parentNode}, sigs{1});
          case {'map'}
            sigs{node} = feval(op, sigs{parentNode}, @identity);
          case {'scan'}
            sigs{node} = feval(op, sigs{parentNode}, @plus, sigs{1});
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
      post(sigs{1}, 2);
      while (testCase.keepMeasuring)
          post(sigs{2}, 1);
      end
      
      % grow an array every time `A` posts 
      function store(x)
        vals = [vals x];
      end
    end
    
  end
  
end