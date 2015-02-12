# squeak
An elegant stimulus presentation framework

Transforming signals
--------------------

`sig1 + sig2` returns a new signal whose values are the addition of the values in each operand signal. Note that `sig1 + sig2` is shorthand for `sig1.plus(sig2)` (or equivalently `plus(sig1, sig2)`), which in turn evaluates to `sig1.map2(@plus, sig2)`. Thus, it is MATLAB's standard `plus` function that is being called on each signal's value.

`signal.map(f)` returns a new signal where its values result from mapping values in `signal` using the function `f`
