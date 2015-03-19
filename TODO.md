# *squeak* TODO list

 * Audit for `sig.Signal` transforms that don't announce sources
 * Proper void signal - no risk of stale links etc
 * Caching of parameter subscript signals
 * A dynamic `struct`-style class `Record`, i.e. add arbitrary fields
   * For inferring parameters
     * Could be used to define a stricter typed struct-signal
   * pars subfields can be assigned during an experiment?
   * Events and Stimuli holders - add arbitrary sub-fields, which are then logged, remoted and in the latter case, rendered
   * Think about arrays of `Record`s
   * Think about `Record` subscripting with signals
   * Defaults: `Option`s `Maybe`s or a `None` perhaps?
 * Random number implementation.
   * How to specify when they should get sampled. In pars? In definition?
 * Sliding window signals, e.g. for quiescence periods
 * `vertcat` and `horzcat` overrides.
 * Ability to cleanup up timers, stop signals etc
 * Arithmetic on arrays in Java subsystem
   * Array-wise
   * Matrix
 * Wrap Java internals in MATLAB.
   * Preliminary support just for simplest cases
   * `struct` <-> `java.util.Map`
   * Scheduling
   * MATLAB listeners for Java events
   * Make MATLAB implementations consistent with Java
   * Creating signals in Java to flatMap?
 * Graphics rendering system.
 * Parameter inference.
   * Infer required parameters.
   * Infer their units & descriptions.
   * Allow overrides of defaults, units and descriptions.
 * Implement `flatMapLatest`. More intuitive naming?
 * Elegant recursion.
   1. If or when should it be timestep delayed?
   2. Naming and semantics that makes risks clear.
 * Integration with GUI.
   * Dashboard for running experiments.
   * Parameter profile management.