/// The errors of `set_weekly_hours`. The range message is the text of the model; the other two are slice texts
/// because the model states none (see the gap report).
sealed class SetWeeklyHoursError implements Exception {
  const SetWeeklyHoursError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// A time range whose end is not after its start, or whose times are missing or malformed.
final class RangeMustEndAfterItStartsError extends SetWeeklyHoursError {
  const RangeMustEndAfterItStartsError() : super('A time range must end after it starts.');
}

/// The signed-in employee is not the host of the schedule.
final class NotScheduleHostError extends SetWeeklyHoursError {
  const NotScheduleHostError() : super('Only the host of this schedule can set its weekly hours.');
}

/// The schedule has no `availability_schedule_created` event, so its lifecycle is not `defined`.
final class ScheduleNotDefinedError extends SetWeeklyHoursError {
  const ScheduleNotDefinedError() : super('This availability schedule does not exist.');
}
