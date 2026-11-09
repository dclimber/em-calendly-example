import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'state.dart';

/// The decider of the `calendar_connection` aggregate for `record_connection_failure`.
///
/// The model gives the transition `access_failed` only from `connecting` and `connected`, and no `invalid_transition`
/// for this command. The model states no rule for `connection_failed` (a repeated failure) or an empty history (a
/// lifecycle gap), so the decider accepts the command in every state and emits `calendar_connection_failed`. The state
/// is folded only to keep the lifecycle visible.
final recordConnectionFailureDecider =
    Decider<RecordConnectionFailureCommand, RecordConnectionFailureState, HostSetupEvent>(
      initialState: const RecordConnectionFailureState(),
      decide: (command, state) async* {
        yield CalendarConnectionFailedEvent(hostId: command.hostId, connectionFailure: command.connectionFailure);
      },
      evolve: (state, event) => switch (event) {
        CalendarConnectionStartedEvent() => const RecordConnectionFailureState(
          lifecycle: CalendarConnectionLifecycleState.connecting,
        ),
        CalendarConnectedEvent() || HostBusyTimesRecordedEvent() => const RecordConnectionFailureState(
          lifecycle: CalendarConnectionLifecycleState.connected,
        ),
        CalendarConnectionFailedEvent() => const RecordConnectionFailureState(
          lifecycle: CalendarConnectionLifecycleState.connectionFailed,
        ),
        _ => state,
      },
    );
