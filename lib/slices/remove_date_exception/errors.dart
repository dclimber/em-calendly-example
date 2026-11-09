/// The errors of `remove_date_exception`. The model states no error text for this workflow, so each message is a slice
/// text (see the gap report).
sealed class RemoveDateExceptionError implements Exception {
  const RemoveDateExceptionError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The signed-in employee is not the host of the schedule.
final class NotScheduleHostError extends RemoveDateExceptionError {
  const NotScheduleHostError() : super('Only the host of this schedule can remove a date exception.');
}

/// The schedule has no `availability_schedule_created` event, so its lifecycle is not `defined`.
final class ScheduleNotDefinedError extends RemoveDateExceptionError {
  const ScheduleNotDefinedError() : super('This availability schedule does not exist.');
}
