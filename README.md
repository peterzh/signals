# squeak
An elegant stimulus presentation framework for your experiments.

Wouldn't it be nice if you could express how you'd like the stimuli in your experiment to be presented in a simple, concise declaration?

* It should be free from the messy details of how it gets done: the tangles of loops, the bedlam of event-handlers, tricky state management and the complexity of graphics rendering.
* You still need data-logging, parameterisation and remote control, but you want that built-in and kept out of your experiment definition too.
* You want that grating to drift? Well, shouldn't that be as simple as: `grating.phase = 2*pi*t*params.temporalFreq`?

This is the goal of squeak.

A simple example
----------------

Defining 3Hz drifting grating patch to be presented for half a second, with blanks of 1s in between:

```matlab
function myGratingPresentation(events, stimuli, t)
stimuli.grating = vis.gabor();    % delcare a gabor grating patch
stimuli.grating.phase = 2*pi*t*3; % phase cycles at 3Hz

stimOff = events.newTrial.delay(0.5); % stimOff occurs 0.5s after new trial starts
events.nextTrial = stimOff.delay(1);  % next trial should start 1s after stimOff
stimuli.show = newTrial.to(stimOff);  % stimulus shown between newTrial & stimOff
end
```

Signals
-------

You can use most of the standard MATLAB operations on signals, with intuitive results, e.g.

```matlab
% if x and y are signals,
z = x + y; % z is a new signal that updates with x and y as their sum
c = 2*cos(y); % c carries twice the cosine of y
posx = x > 0; % posx updates with x with true if x > 0, false otherwise
```
In each case, these expressions return a new signal whose value will update as any of the source signals change.

Note that `sig1 + sig2` is shorthand for `sig1.plus(sig2)` (or equivalently `plus(sig1, sig2)`), which ultimately evalutes to `sig1.map2(@plus, sig2)`. Thus, it is MATLAB's standard `plus` function that is being called on each signal's value.


Other signal transformations
----------------------------

`signal.map(f)` returns a new signal where its values result from mapping values in `signal` using the function `f`.

`signal.map2(f, otherSignal)` returns a new signal where its values result from mapping values in `signal` and `otherSignal` using the function `f`.
