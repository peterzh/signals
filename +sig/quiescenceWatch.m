function qevt = quiescenceWatch(newPeriod, t, x, threshold)
%sig.quiescenceWatch Trigger when a signal doesn't change for some period
%
%   qevt = sig.quiescenceWatch(newPeriod, t, x, [threshold]) returns a
%   signal that once activated, triggers when 'x' does not change more than
%   some threshold after a specified period. The trigger watch is activated
%   by a new required period arriving in 'newPeriod'. 't' should be a time
%   signal to monitor. 'threshold' optionally specifies the maximum amount
%   of change to tolerate before restarting the watch period (if
%   unspecified it defaults to zero).

if nargin < 4
  threshold = 1;
end

newState = newPeriod.map(@initState);  

state = scan(t.delta(), @tUpdate, x.delta(), @xUpdate, newState, 'pars', threshold);
state = state.subscriptable();
% event signal is derived by monitoring the armed field of state for new
% false values (i.e. when it's released).
qevt = state.armed.skipRepeats().not().then(true);

end
%% helper functions
function state = initState(dur)
 state = struct('win', dur, 'remaining', dur, 'mvmt', 0, 'armed', true);
end

function state = tUpdate(dt, state, ~)
if state.armed
  state.remaining = max(state.remaining - dt, 0);
  if state.remaining == 0
    state.armed = false; % state is now released
  end
end
end

function state = xUpdate(dx, state, thresh)
if state.armed
  state.mvmt = state.mvmt + abs(dx);
  if state.mvmt > thresh % reached threshold, so reset
    state.mvmt = 0;
    state.remaining = state.win;
  end
end
end