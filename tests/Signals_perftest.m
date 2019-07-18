classdef Signals_perftest < matlab.perftest.TestCase
% Runs performance tests for Signals
%
% Performs benchmarking for updating a signal via various operations (via
% `test_MexOps` and `test_SignalOps`), and performs benchmarking for 
% updating each signal in networks of various widths and depths (30 to 
% 1000 nodes spread across 2 to 20 layers, via `test_network` method). 
% (*Note: for reference, the `docs\examples\advancedChoiceWorld` exp def 
% has 338 nodes over 10 layers).
%
% In this class, the `Net` property is a Signals network, in which the 
% `A` & `B` properties are treated as "input layer" origin signals from 
% which all other signals are created.
%   
% Example - display the mean measured time for running each test:
%   results = runperf('Signals_perftest.m');
%   fullTableResults = vertcat(results.Samples);
%   meanTimeByTestTable = varfun(@mean, fullTableResults,...
%     'InputVariables', 'MeasuredTime', 'GroupingVariables', 'Name')
%
% @todo: cases for `delay` and `flatten` need to be added to `test_SignalOps`
  
  properties 
    
    % Signals network (`sig.Net` object)
    Net
    % Origin signal (`sig.node.OriginSignal` object)
    A
    % Origin signal (`sig.node.OriginSignal` object)
    B
    % Number of test repetitions
    Reps = 1000
    % Operations which are run directly in compiled mexnet
    % (`Containers.Map` object with keys as numeric op codes and values as
    % signal methods)
    MexOps  
    
  end
  
  properties (TestParameter)
    
    % The numeric values corresponding to the op code in
    % `sig.node.transfererOpCode` for those operations which are run 
    % in the compiled mexnet. 
    MexOpKey = num2cell([1:6 10:14 30 40])
    % sig.node.Signal method operations which have transfer functions 
    % (in +sig/+transfer). Methods not included are redundant on these.
    SignalOp = {@subscriptable, @at, @keepWhen, @map, @mapn, @scan,... 
      @selectFrom, @indexOfFirst, @merge, @to, @skipRepeats, @delay, ...
      @identity, @flatten, @log, @subsref}
    % Number of total nodes in the network
    NumNodes = {30 120 350 1000}
    % Number of layers of nodes in the network
    Depth = {2 5 10 20}
    % Flag for whether or not to only test MexOps in `test_network`
    OnlyMexOps = {0 1}
  end
  
  methods (TestMethodSetup)
    
    function createNetwork(testCase)
      % Creates the signals network in which we will run the tests
      
      testCase.Net = sig.Net;
      testCase.A = testCase.Net.origin('A');
      testCase.B = testCase.Net.origin('B');      
      % The operations which are run in the compiled mexnet 
      MexOpVal = {@plus, @minus, @times, @mtimes, @rdivide, @mrdrivide,...
        @gt, @ge, @lt, @le, @eq, @numel, @flattenStruct};  
      % Containers.Map object for identifying MexOpVals by their MexOpKeys
      testCase.MexOps = containers.Map(testCase.MexOpKey, MexOpVal);
    end
    
  end
    
  methods (Test)
    
    function test_MexOps(testCase, MexOpKey)
      % Benchmarks updating a single signal with mex operations.
      %
      % There are two "switch" blocks: in the first, we create a signal 
      % from the operation we wish to test, and in the second we test the 
      % update of that signal for that operation.
      
      % create signal `c` from op
      switch MexOpKey
        
        % logical & scalar arithmetic operations
        case {1,2,3,5,10,11,12,13,14,30}
          % create signal `c` from op:
          c = feval(testCase.MexOps(MexOpKey), testCase.A, testCase.B); %#ok<*NASGU>
          post(testCase.B, 2);
          
        % matrix arithmetic
        case {4,6}
          c = feval(testCase.MexOps(MexOpKey), testCase.A, testCase.B);
          post(testCase.B, magic(2));
          
        % `flattenStruct`
        case {40}
          c = feval(testCase.MexOps(MexOpKey), testCase.B);
          s = struct('a', testCase.A);
          post(testCase.B, s);
          
      end
      
      % test time it takes for op to update signal `c`      
      switch mexOpKey
        
        % matrix arithmetic
        case {4,6}
          while (testCase.keepMeasuring)
            for i = 1:testCase.Reps
              post(testCase.A, magic(2));
            end
          end
          
        otherwise
          while (testCase.keepMeasuring)
            for i = 1:testCase.Reps
              post(testCase.A, 1);
            end
          end
      end
      
    end      
   
    function test_SignalOps(testCase, SignalOp)
      % Benchmarks updating a single signal with signal methods
      %
      % In the "switch" block, we create a signal from the signal method
      % we wish to test, and in the "while" loop we we test the update of 
      % that signal for that method.
      
      % create signal `c` from method
      switch func2str(SignalOp)
        
            % methods that create a signal from only 1 input
            case{'skipRepeats', 'identity', 'log'}
              c = feval(SignalOp, testCase.A);
              
            % methods that can create a signal from only 2 inputs
            case {'at', 'keepWhen', 'selectFrom', 'indexOfFirst', 'merge', 'to',  }
              c = feval(SignalOp, testCase.A, testCase.B);
              post(testCase.B, 2);
              
            case {'subscriptable'}
              s = struct('a', 1);
              c = feval(SignalOp, testCase.A);
              c_a = c.a;
              
            case {'subsref'}
              c = feval(SignalOp, testCase.A, 2);

            case {'map', 'mapn'}
              c = feval(SignalOp, testCase.A, @identity);
              
            case {'scan'}
              c = feval(SignalOp, @plus, 0);

      end
      
      % test time it takes for method to update `c`:
      while (testCase.keepMeasuring)
        for i = 1:testCase.Reps
          post(testCase.A, 1);
        end
      end
      
    end
    
    function test_network(testCase, NumNodes, Depth, OnlyMexOps)
      % benchmarks updating all signals in networks of various sizes
      
      % set-up network to test
      sigs = cell(NumNodes); % cell array of all signals to be tested
      sigs{1} = testCase.A;
      sigs{2} = testCase.B;
      
      % number of ops to sample evenly
      numOps = iff(OnlyMexOps, length(testCase.BasicOps),... 
        length(testCase.MainOps));
      nodeNum = 1; % counter
      
      for node = 3:NumNodes
        % can't use `iff` here b/c we are returning a function handle
        if OnlyBasicOps
          op = testCase.BasicOps{mod(nodeNum, numOps)+1};
        else
          op = testCase.MainOps{mod(nodeNum, numOps)+1};
        end
        
        % we'll use this to distribute nodes across layers evenly
        parentNode = iff(mod((node-3), Depth) == 0, 2, node-1);
        
        switch func2str(op)  
          % for ops that do not create a new signal upon posting 1 to
          % `testCase.A`, change op to `@gt`
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