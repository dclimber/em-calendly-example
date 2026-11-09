/// The errors of `add_date_exception`. The range message is the text of the model's `range_must_end_after_it_starts`
/// scenario (of `set_weekly_hours`), applied to the same kind of range; the other two are slice texts because this
/// workflow's model states none (see the gap report).
sealed class AddDateExceptionError implements Exception {
  const AddDateExceptionError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// An hour range whose end is not after its start, or whose times are missing or malformed.
final class RangeMustEndAfterItStartsError extends AddDateExceptionError {
  const RangeMustEndAfterItStartsError() : super('A time range must end after it starts.');
}

/// The signed-in employee is not the host of the schedule.
final class NotScheduleHostError extends AddDateExceptionError {
  const NotScheduleHostError() : super('Only the host of this schedule can add a date exception.');
}

/// The schedule has no `availability_schedule_created` event, so its lifecycle is not `defined`.
final class ScheduleNotDefinedError extends AddDateExceptionError {
  const ScheduleNotDefinedError() : super('This availability schedule does not exist.');
}
