import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

final _timePattern = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

/// Minutes after midnight of an `HH:mm` time, or null when the text is not such a time.
int? _minutes(String text) {
  final match = _timePattern.firstMatch(text);
  if (match == null) return null;
  return int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
}

/// Whether [range] has a start and an end, and the end is after the start.
bool _isValidRange(ExceptionHoursRange range) {
  final start = _minutes(range.startTime);
  final end = _minutes(range.endTime);
  return start != null && end != null && end > start;
}

/// The decider of the `availability_schedule` aggregate for `add_date_exception`.
///
/// The lifecycle transition requires `defined`, so a schedule that was never created is refused. The model states no
/// rule for a caller who is not the host; the decider refuses that too. Empty hours are the whole date unavailable,
/// so the decider accepts an empty list. Each hour range that is given must end after it starts.
final addDateExceptionDecider = Decider<AddDateExceptionCommand, AddDateExceptionState, HostSetupEvent>(
  initialState: const AddDateExceptionState(),
  decide: (command, state) async* {
    if (state.lifecycle != AvailabilityScheduleLifecycleState.defined) throw const ScheduleNotDefinedError();
    if (state.hostId != command.hostId) throw const NotScheduleHostError();
    if (!command.exceptionHours.items.every(_isValidRange)) throw const RangeMustEndAfterItStartsError();
    yield DateExceptionAddedEvent(
      scheduleId: command.scheduleId,
      exceptionDate: command.exceptionDate,
      exceptionHours: command.exceptionHours,
    );
  },
  evolve: (state, event) => switch (event) {
    AvailabilityScheduleCreatedEvent() => AddDateExceptionState(
      lifecycle: AvailabilityScheduleLifecycleState.defined,
      hostId: event.hostId,
    ),
    _ => state,
  },
);
