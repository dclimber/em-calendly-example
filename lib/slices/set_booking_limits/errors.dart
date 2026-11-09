/// The errors of `set_booking_limits`. The model states no error text for this command, so each message is a slice
/// text (see the gap report).
sealed class SetBookingLimitsError implements Exception {
  const SetBookingLimitsError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The signed-in employee is not the host of the schedule.
final class NotScheduleHostError extends SetBookingLimitsError {
  const NotScheduleHostError() : super('Only the host of this schedule can set its booking limits.');
}

/// The schedule has no `availability_schedule_created` event, so its lifecycle is not `defined`.
final class ScheduleNotDefinedError extends SetBookingLimitsError {
  const ScheduleNotDefinedError() : super('This availability schedule does not exist.');
}
