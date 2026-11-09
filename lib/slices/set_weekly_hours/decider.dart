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

/// Whether [entry] has a start and an end, and the end is after the start.
bool _isValidRange(WeeklyHoursEntry entry) {
  final start = _minutes(entry.startTime);
  final end = _minutes(entry.endTime);
  return start != null && end != null && end > start;
}

/// The decider of the `availability_schedule` aggregate for `set_weekly_hours`.
///
/// The lifecycle transition requires `defined`, so a schedule that was never created is refused. The model states no
/// rule for a caller who is not the host; the decider refuses that too. Each range must end after it starts.
final setWeeklyHoursDecider = Decider<SetWeeklyHoursCommand, SetWeeklyHoursState, HostSetupEvent>(
  initialState: const SetWeeklyHoursState(),
  decide: (command, state) async* {
    if (state.lifecycle != AvailabilityScheduleLifecycleState.defined) throw const ScheduleNotDefinedError();
    if (state.hostId != command.hostId) throw const NotScheduleHostError();
    if (!command.weeklyHours.items.every(_isValidRange)) throw const RangeMustEndAfterItStartsError();
    yield WeeklyHoursSetEvent(scheduleId: command.scheduleId, weeklyHours: command.weeklyHours);
  },
  evolve: (state, event) => switch (event) {
    AvailabilityScheduleCreatedEvent() => SetWeeklyHoursState(
      lifecycle: AvailabilityScheduleLifecycleState.defined,
      hostId: event.hostId,
    ),
    _ => state,
  },
);
