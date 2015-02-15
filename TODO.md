# *squeak* TODO list

 * A 'dynamic' structure-style class, i.e. add arbitrary fields
   * For inferring parameters
     * Could be used to define a stricter typed struct-signal
   * Events and Stimuli holders - add arbitrary sub-fields, which are then logged, remoted and in the latter case, rendered
 * `vertcat` and `horzcat` overrides.
 * Add array arithmetic operations support to Java subsystem.
 * Add matrix arithmetic operations support to Java subsystem.
 * Wrap Java internals in MATLAB.
   * Preliminary support just for simplest cases
   * `struct` <-> `java.util.Map`
   * Scheduling
   * MATLAB listeners for Java events
   * Make MATLAB implementations consistent with Java
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


