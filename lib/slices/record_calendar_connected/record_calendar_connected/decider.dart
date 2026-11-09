import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'state.dart';

/// The decider of the `calendar_connection` aggregate for `record_calendar_connected`.
///
/// The model gives the transition `access_granted` only from `connecting`, and no `invalid_transition` for this
/// command. The model states no rule for `connected`, `connection_failed`, or an empty history (a lifecycle gap),
/// so the decider accepts the command in every state and emits `calendar_connected`. The state is folded only to
/// keep the lifecycle visible.
final recordCalendarConnectedDecider =
    Decider<RecordCalendarConnectedCommand, RecordCalendarConnectedState, HostSetupEvent>(
      initialState: const RecordCalendarConnectedState(),
      decide: (command, state) async* {
        yield CalendarConnectedEvent(hostId: command.hostId, calendarAccount: command.calendarAccount);
      },
      evolve: (state, event) => switch (event) {
        CalendarConnectionStartedEvent() => const RecordCalendarConnectedState(
          lifecycle: CalendarConnectionLifecycleState.connecting,
        ),
        CalendarConnectedEvent() || HostBusyTimesRecordedEvent() => const RecordCalendarConnectedState(
          lifecycle: CalendarConnectionLifecycleState.connected,
        ),
        CalendarConnectionFailedEvent() => const RecordCalendarConnectedState(
          lifecycle: CalendarConnectionLifecycleState.connectionFailed,
        ),
        _ => state,
      },
    );
