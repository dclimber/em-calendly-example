import '../../bounded_contexts/host_setup/api.dart';

/// Sets the recurring weekly hours of an availability schedule (`set_weekly_hours`).
///
/// `host_id` is not a field of the model's command. It is the signed-in host, which the decider checks against the
/// schedule's host (the model states no rule for this; see the gap report in the slice notes).
final class SetWeeklyHoursCommand {
  const SetWeeklyHoursCommand({required this.scheduleId, required this.hostId, required this.weeklyHours});

  final ScheduleId scheduleId;
  final HostId hostId;
  final WeeklyHours weeklyHours;

  @override
  bool operator ==(Object other) =>
      other is SetWeeklyHoursCommand &&
      other.scheduleId == scheduleId &&
      other.hostId == hostId &&
      other.weeklyHours == weeklyHours;

  @override
  int get hashCode => Object.hash(scheduleId, hostId, weeklyHours);

  @override
  String toString() => 'SetWeeklyHoursCommand($scheduleId, $hostId, $weeklyHours)';
}
