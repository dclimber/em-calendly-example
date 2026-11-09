/// The errors of `change_date_exception`. The range message is the text of the model's `range_must_end_after_it_starts`
/// scenario (of `set_weekly_hours`), applied to the same kind of range; the other two are slice texts because this
/// workflow's model states none (see the gap report).
sealed class ChangeDateExceptionError implements Exception {
  const ChangeDateExceptionError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// An hour range whose end is not after its start, or whose times are missing or malformed.
final class RangeMustEndAfterItStartsError extends ChangeDateExceptionError {
  const RangeMustEndAfterItStartsError() : super('A time range must end after it starts.');
}

/// The signed-in employee is not the host of the schedule.
final class NotScheduleHostError extends ChangeDateExceptionError {
  const NotScheduleHostError() : super('Only the host of this schedule can change a date exception.');
}

/// The schedule has no `availability_schedule_created` event, so its lifecycle is not `defined`.
final class ScheduleNotDefinedError extends ChangeDateExceptionError {
  const ScheduleNotDefinedError() : super('This availability schedule does not exist.');
}
