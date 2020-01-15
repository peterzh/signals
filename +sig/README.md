## +Sig:
The +sig package contains most of the classes and functions for implementing Signals logic in MATLAB.
       
### Examples
Create a new Signals network and add some signals to the network
```matlab
net = sig.Net;
input = net.origin('input Signal');
dependent = input^2;
h = output(dependent);
input.post(2)
```

Plot some signals live using the command window
```matlab
import sig.test.sequence
import sig.test.timeplot

seq = sequence(1:10:1000)
input = net.origin('input Signal');
dependent = input^2;
```

Show a visual stimulus using command prompt
```matlab
import sig.test.playgroundPTB
import sig.test.timeplot
[t, setgraphic] = playgroundPTB('Main loop control');
vs = StructRef;

grating = vis.grating(t); % we want a gabor grating patch
grating.phase = 2*pi*t*3; % with its phase cycling at 3Hz
grating.show = true;
vs.grating = grating;
setgraphic(vs);
```

## Contents:

Below is a summery of folders contained.  For a full list of functions and classes see `Contents.m`.

- `+test/`    - Functions for testing and plotting Signals via the Command.
- `+node/`    - Implementation of Signals as Node objects.
- `+scan/`    - Functions suppoting the Signals scan method.
- `transfer/` - Transfer functions for implementing various Signals methods.
