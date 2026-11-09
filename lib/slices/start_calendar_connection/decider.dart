import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `calendar_connection` aggregate for `start_calendar_connection`.
///
/// `start_first_connection` (no stream yet) and `retry_failed_connection` (from `connection_failed`) both emit
/// `calendar_connection_started`. `start_when_already_connected` rejects the command in `connected`.
/// The model states no rule for `connecting`, so the decider accepts the command there (a lifecycle gap).
final startCalendarConnectionDecider =
    Decider<StartCalendarConnectionCommand, StartCalendarConnectionState, HostSetupEvent>(
      initialState: const StartCalendarConnectionState(),
      decide: (command, state) async* {
        if (state.lifecycle == CalendarConnectionLifecycleState.connected) {
          throw const StartWhenAlreadyConnectedError();
        }
        yield CalendarConnectionStartedEvent(hostId: command.hostId);
      },
      evolve: (state, event) => switch (event) {
        CalendarConnectionStartedEvent() => const StartCalendarConnectionState(
          lifecycle: CalendarConnectionLifecycleState.connecting,
        ),
        CalendarConnectedEvent() || HostBusyTimesRecordedEvent() => const StartCalendarConnectionState(
          lifecycle: CalendarConnectionLifecycleState.connected,
        ),
        CalendarConnectionFailedEvent() => const StartCalendarConnectionState(
          lifecycle: CalendarConnectionLifecycleState.connectionFailed,
        ),
        _ => state,
      },
    );
