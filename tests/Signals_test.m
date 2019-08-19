classdef Signals_test < matlab.unittest.TestCase
  properties
    net
    A
    B
    C
  end
  
  methods (TestClassSetup)
    function createNetwork(testCase)
      testCase.net = sig.Net;
    end
  end
  
  methods (TestMethodSetup)
    function setupInputSignals(testCase)
      testCase.A = testCase.net.origin('a');
      testCase.B = testCase.net.origin('b');
      testCase.C = testCase.net.origin('c');
      
      testCase.addTeardown(@delete, [testCase.A, testCase.B, testCase.C])
    end
  end
  
  methods (Test)
    function testMap(testCase)
      % Tests for map method
      a = testCase.A;
      
      % Test mapping of signal through MATLAB function
      b = a.map(@fliplr);
      arr = 1:3;
      a.post(arr)
      testCase.verifyEqual(b.Node.CurrValue, fliplr(arr), ...
        'Unexpected output when mapping function')
      testCase.verifyMatches(b.Name, '\w+\.map\(@\w+\)', 'Unexpected Name')
      
      % Test mapping to a constant
      v = rand;
      b = a.map(v);
      a.post(arr)
      testCase.verifyEqual(b.Node.CurrValue, v, ...
        'Unexpected output when mapping constant')
      testCase.verifyMatches(b.Name, '\w+\.map\([\d|\.]*\)', 'Unexpected Name')
      
      % Test transfer function directly
      % No new changes in network; 
      args = {testCase.net.Id, a.Node.Id, [], @identity};
      [~, valset] = sig.transfer.map(args{:});
      testCase.verifyTrue(~valset, 'Expected ''valset'' to be false')
      % Update one of the input nodes
      actual = submit(testCase.net.Id, a.Node.Id, v);
      testCase.verifyEqual(sort([a.Node.Id; b.Node.Id]), actual, ...
        'Unexpected affected node indicies returned')
      [val, valset] = sig.transfer.map(args{:});
      testCase.verifyTrue(valset, 'Expected ''valset'' to be true')
      testCase.verifyEqual(val, v, 'Failed to re-evaluate function')
    end
    
    function testMapn(testCase)
      % Tests for mapn method
      [a, b] = deal(testCase.A, testCase.B);
            
      % Test mapping multiple input signals to multiple output signals
      [X, Y] = a.mapn(b, @meshgrid);
      
      % Test with these input values:
      xx = 1:5; yy = 5:10;
      [expectedX, expectedY] = meshgrid(xx, yy);
      
      % Verify that dependent signals only updated when all input signals
      % have values
      a.post(xx);
      actual = [X.Node.CurrValue Y.Node.CurrValue];
      testCase.verifyEmpty(actual, 'Values mapped before all inputs have values')
      
      b.post(yy);
      actualX = X.Node.CurrValue;
      actualY = Y.Node.CurrValue;
      
      % Verify Signals implementation yields equal output values
      isEqualX = isequal(expectedX, actualX);
      isEqualY = isequal(expectedY, actualY);
      testCase.verifyTrue(isEqualX && isEqualY, 'Failed to assign expected outputs')
      % Verify Name property
      testCase.verifyMatches(X.Name, 'mapn\(\w+, \w+, @meshgrid\)', 'Unexpected Name')
      testCase.verifyMatches(Y.Name, '.*[2]', 'Unexpected Name')
      
      % Test transfer function directly
      % No new changes in network; 
      args = {testCase.net.Id, [a.Node.Id, b.Node.Id], [], {@meshgrid, 1}};
      [~, valset] = sig.transfer.mapn(args{:});
      testCase.verifyTrue(~valset, 'Expected ''valset'' to be false')
      % Update one of the input nodes
      actual = submit(testCase.net.Id, a.Node.Id, xx);
      testCase.verifyEqual(sort([a.Node.Id; X.Node.Id; Y.Node.Id]), actual, ...
        'Unexpected affected node indicies returned')
      [val, valset] = sig.transfer.mapn(args{:});
      testCase.verifyTrue(valset, 'Expected ''valset'' to be true')
      testCase.verifyEqual(val, expectedX, 'Failed to re-evaluate function')
    end
    
    function test_size(testCase)
      % Test for the size method
      a = testCase.A;
      n = randi(10);
      
      % 1 input, 1 output
      sz = size(a);
      testCase.assertTrue(isa(sz, 'sig.Signal'), ...
        ['Unexpected output: expected sig.Signal but returned ', class(sz)])
      a.post(1:n);
      testCase.verifyEqual(sz.Node.CurrValue, [1 n], ...
        'Unexpected value for 1 input, 1 output map of size')
      % Verify Name property
      testCase.verifyMatches(sz.Name, 'size\(\w+\)', 'Unexpected Name')
      
      % 1 input, 2 outputs
      [sz_m, sz_n] = size(a);
      a.post(1:n)
      actual = [sz_m.Node.CurrValue, sz_n.Node.CurrValue];
      testCase.verifyEqual(actual, [1 n], ...
        'Unexpected value for 1 input, 1 output map of size')
      % Verify Name property
      testCase.verifyMatches(sz_m.Name, 'size\(\w+\) over dim \d+', 'Unexpected Name')
      testCase.verifyMatches(sz_n.Name, 'size\(\w+\) over dim \d+', 'Unexpected Name')
      
     % 2 input, 1 output
      [sz] = size(a, 2);
      a.post(1:n)
      testCase.verifyEqual(sz.Node.CurrValue, n, ...
        'Unexpected value for map of size along specified dimention')
      
      % 2 inpust, 2 outputs
      [~, sz] = size(a, 2); %#ok<ASGLU>
      testCase.verifyError(@()a.post(1:n), 'MATLAB:maxlhs', ...
        'Unexpected error identifier')
    end
    function test_min(testCase)
      % Test for the min method
    end
    function test_max(testCase)
      % Test for the max method
    end
    function test_exp(testCase)
      % Test for the exp method
    end
  end
end