import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `availability_schedule` aggregate for `remove_date_exception`.
///
/// The lifecycle transition requires `defined`, so a schedule that was never created is refused. The model states no
/// rule for a caller who is not the host; the decider refuses that too. The model states no rule for removing a date
/// that has no current exception, so the decider accepts it (see the gap report).
final removeDateExceptionDecider = Decider<RemoveDateExceptionCommand, RemoveDateExceptionState, HostSetupEvent>(
  initialState: const RemoveDateExceptionState(),
  decide: (command, state) async* {
    if (state.lifecycle != AvailabilityScheduleLifecycleState.defined) throw const ScheduleNotDefinedError();
    if (state.hostId != command.hostId) throw const NotScheduleHostError();
    yield DateExceptionRemovedEvent(scheduleId: command.scheduleId, exceptionDate: command.exceptionDate);
  },
  evolve: (state, event) => switch (event) {
    AvailabilityScheduleCreatedEvent() => RemoveDateExceptionState(
      lifecycle: AvailabilityScheduleLifecycleState.defined,
      hostId: event.hostId,
    ),
    _ => state,
  },
);
