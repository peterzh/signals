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
      expected = 'mapn\(\w+, \w+, @meshgrid\)';
      testCase.verifyMatches(X.Name, expected, 'Unexpected Name')
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
      expected = 'size\(\w+\) over dim \d+';
      testCase.verifyMatches(sz_m.Name, expected, 'Unexpected Name')
      testCase.verifyMatches(sz_n.Name, expected, 'Unexpected Name')
      
     % 2 input, 1 output
      [sz] = size(a, 2);
      a.post(1:n)
      testCase.verifyEqual(sz.Node.CurrValue, n, ...
        'Unexpected value for map of size along specified dimention')
      
      % 2 inputs, 2 outputs
      [~, sz] = size(a, 2);  %#ok<*ASGLU>
      testCase.verifyError(@()a.post(1:n), 'MATLAB:maxlhs', ...
        'Unexpected error identifier')
    end
    
    function test_colon(testCase)
      % Test for the colon method
      [a, b, c] = deal(testCase.A, testCase.B, testCase.C);
      i = 3; j = 14; k = 0.5;
      
      % Test two inputs
      s = a:b;
      a.post(i), b.post(j)
      testCase.verifyEqual(s.Node.CurrValue, i:j, 'Failed on two input')
      testCase.verifyMatches(s.Name, '\w+ : \w+', 'Unexpected Name')
      
      % Test three inputs
      s = a:c:b;
      c.post(k)
      testCase.verifyEqual(s.Node.CurrValue, i:k:j, 'Failed on three input')
      testCase.verifyMatches(s.Name, '\w+ : \w+ : \w+', 'Unexpected Name')
    end
    
    function test_min(testCase)
      % Test for the min method
      [a, b] = deal(testCase.A, testCase.B);
      
      [M,I] = min(a);
      a.post(magic(3))
      testCase.verifyEqual(M.Node.CurrValue, [3,1,2], ...
        'Failed to return minimum values')
      testCase.verifyEqual(I.Node.CurrValue, [2,1,3], ...
        'Failed to return indicies')
      testCase.verifyMatches(M.Name, 'min\(\w+\)', 'Unexpected Name')
      
      [M,I] = min(a,[],b);
      expected = 'min\(\w+\) over dim \w+';
      testCase.verifyMatches(M.Name, expected, 'Unexpected Name')
      post(b,2)
      testCase.verifyEqual(M.Node.CurrValue, [1;3;2], ...
        'Failed to return minimum values')
      testCase.verifyEqual(I.Node.CurrValue, [2;1;3], ...
        'Failed to return indicies')
      
      clear('I')
      M = min(a,b);
      testCase.verifyMatches(M.Name, 'min\(\w+,\w+\)', 'Unexpected Name')
      post(a,magic(2)), post(b,2)
      testCase.verifyEqual(M.Node.CurrValue, [1,2;2,2], ...
        'Failed to return minimum values')
    end
    
    function test_max(testCase)
      % Test for the max method
      [a, b] = deal(testCase.A, testCase.B);
      
      [M,I] = max(a);
      a.post(magic(3))
      testCase.verifyEqual(M.Node.CurrValue, [8,9,7], ...
        'Failed to return maximum values')
      testCase.verifyEqual(I.Node.CurrValue, [1,3,2], ...
        'Failed to return indicies')
      testCase.verifyMatches(M.Name, 'max\(\w+\)', 'Unexpected Name')
      
      [M,I] = max(a,[],b);
      expected = 'max\(\w+\) over dim \w+';
      testCase.verifyMatches(M.Name, expected, 'Unexpected Name')
      post(b,2)
      testCase.verifyEqual(M.Node.CurrValue, [8;7;9], ...
        'Failed to return maximum values')
      testCase.verifyEqual(I.Node.CurrValue, [1;3;2], ...
        'Failed to return indicies')
      
      clear('I')
      M = max(a,b);
      testCase.verifyMatches(M.Name, 'max\(\w+,\w+\)', 'Unexpected Name')
      post(a,magic(2)), post(b,2)
      testCase.verifyEqual(M.Node.CurrValue, [2,3;4,2], ...
        'Failed to return maximum values')
    end
    
    function test_exp(testCase)
      % Test for the exp method
      a = testCase.A;
      b = exp(a);
      e = exp(1);
      
      testCase.verifyMatches(b.Name, 'exp\(\w+\)', 'Unexpected Name')
      a.post(1)
      testCase.verifyEqual(b.Node.CurrValue, e)
    end
    
  end
end