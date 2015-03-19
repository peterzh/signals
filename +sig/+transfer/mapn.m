function [val, valset] = mapn(net, inputs, node, f)
%XSIG.TRANSFER.MAPN Summary of this function goes here
%   Detailed explanation goes here

n = numel(inputs);
inpvals = cell(n, 1);
wvset = false(n, 1);
for inp = 1:n
  [wv, wvset(inp)] = workingNodeValue(net, inputs(inp));
  if wvset(inp) % value follows working value first
    inpvals{inp} = wv;
  else % cvset % falls back to current value
    [cv, cvset] = currNodeValue(net, inputs(inp));
    if cvset
      inpvals{inp} = cv;
    else % finding an input with no value set -> no output
      val = [];
      valset = false;
      return
    end
  end
end

if any(wvset)
  % canonical line: call map function with latest inputs. new output is
  % result from map
  val = f(inpvals{:});
  valset = true;
else % no inputs have a working value -> no output
  val = [];
  valset = false;
end

end