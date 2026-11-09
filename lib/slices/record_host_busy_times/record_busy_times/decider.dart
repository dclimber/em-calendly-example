import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'state.dart';

/// The decider of the `calendar_connection` aggregate for `record_busy_times`.
///
/// The model gives the transition `busy_times_refreshed` only from `connected`, and no `invalid_transition` for this
/// command. The model states no rule for `connecting`, `connection_failed`, or an empty history (a lifecycle gap),
/// so the decider accepts the command in every state and emits `host_busy_times_recorded`. The state is folded only to
/// keep the lifecycle visible.
final recordBusyTimesDecider = Decider<RecordBusyTimesCommand, RecordBusyTimesState, HostSetupEvent>(
  initialState: const RecordBusyTimesState(),
  decide: (command, state) async* {
    yield HostBusyTimesRecordedEvent(hostId: command.hostId, busyIntervals: command.busyIntervals);
  },
  evolve: (state, event) => switch (event) {
    CalendarConnectionStartedEvent() => const RecordBusyTimesState(
      lifecycle: CalendarConnectionLifecycleState.connecting,
    ),
    CalendarConnectedEvent() || HostBusyTimesRecordedEvent() => const RecordBusyTimesState(
      lifecycle: CalendarConnectionLifecycleState.connected,
    ),
    CalendarConnectionFailedEvent() => const RecordBusyTimesState(
      lifecycle: CalendarConnectionLifecycleState.connectionFailed,
    ),
    _ => state,
  },
);
