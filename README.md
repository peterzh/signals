# *squeak*
Simple, elegant and flexible stimulus presentation in MATLAB.

Wouldn't it be nice if you could describe the presentation of stimuli in your experiment with simple, concise code? i.e.

* Something like making a grating drift should be as straightforward as its mathematical description: `grating.phase = 2*pi*t*temporalFreq`.
* It should be free from the messy details of how it actually gets presented: no unpredictable loops, tangles of event-handlers, tricky state management nor low-level graphics rendering.
* ...and yet, still benefit from easy data-logging, parameterisation and remote control.


This is the goal of *squeak*.

## Hello, Grating!

Here's how you could define a 3Hz drifting grating patch to be presented for half a second (with intervening 1 second blank periods), using *squeak*:

```matlab
function flashedGrating(events, stimuli, t)
stimuli.grating = vis.gabor();    % we want a gabor grating patch
stimuli.grating.phase = 2*pi*t*3; % with it's phase cycling at 3Hz

stimOff = events.newTrial.delay(0.5); % stimOff occurs 0.5s after new trial starts
events.nextTrial = stimOff.delay(1);  % next trial should start 1s after stimOff
stimuli.show = newTrial.to(stimOff);  % stimulus visible between trial onset & stimOff
end
```

Now let's present our grating 15 times:

```matlab
log = exp.runTrials(@flashedGrating, 15);
```

Note that we didn't specify a position for the grating, nor its spatial frequency, so it will always appear using some defaults (e.g. as defined in `vis.gabor()`; positioned directly ahead with 1 cyc/&deg;). In fact, we would probably like all our stimulus attributes parameterised so they can be varied, by experiment, by trial, by whatever:

```matlab
function flashedGrating2(events, stimuli, t, pars) % take extra arg for parameters
stimuli.grating = vis.gabor();
% pars.(parameterName) refers to a named (potentially changing) parameter
stimuli.grating.azimuth = pars.azimuth;
stimuli.grating.altitude = pars.altitude;
stimuli.grating.spatialFreq = pars.spatialFreq;
stimuli.grating.phase = 2*pi*t*pars.temporalFreq;

stimOff = events.newTrial.delay(pars.stimDuration);
events.nextTrial = stimOff.delay(pars.stimInterval);
stimuli.show = newTrial.to(stimOff);
end
```

Now, we're going to need some values for those parameters before we can actually run an experiment. One way is to pass in a MATLAB `struct` with fields corresponding to each named parameter. But, a simple GUI for configuring them first would be nice:

```matlab
paramValues = exp.promptForParams(@flashedGrating2);
log = exp.runTrials(@flashedGrating2, paramValues);
```

The `exp.promptForParams` function actually calls your presentation definition just to infer what parameters it requires. It will then show a (blocking) GUI requesting those parameters, and return your final settings in an appropriate `struct`. Finally, we use them to run the experiment presentation, all parameterised and stuff.

## Signals

*TODO: Introduce signals here*

You can use most of the standard MATLAB operations on signals, with intuitive results, e.g.

```matlab
% if x and y are signals,
z = x + y; % z is a new signal that updates with x and y as their sum
c = 2*cos(y); % c will always be twice the cosine of y
posx = x > 0; % posx updates with x, true if x > 0, false otherwise
```
In each case, these expressions return a new signal whose value will update as any of the source signals change.

These operations actually use the signal mapping functions *TODO: make link to below*. E.g. `sig1 + sig2` is shorthand for `sig1.plus(sig2)` (or equivalently `plus(sig1, sig2)`), which ultimately evaluates to `sig1.map2(@plus, sig2)`. Thus, here MATLAB's standard `plus` function is being called on each signal's value.

### Useful signal transformations

`signal.delay(period)` returns a new signal that is a time delayed version of `signal`. I.e. each time `signal`'s value changes, the resultant signal's value will change to the same value, but `period` seconds later. `period` can be a constant or a time-varying signal.

`signal.to(otherSignal)` *TODO*

`signal.at(otherSignal)` *TODO*

`signal.if(truthValue, falseValue)` *TODO*

### Mapping signals

`signal.map(f)` returns a new signal whose values result from mapping values in `signal` using the function `f`.

`signal.map2(f, otherSignal)` returns a new signal where its values result from mapping values in `signal` and `otherSignal` using the function `f`. Note that the resultant signal updates if either source signal changes.
