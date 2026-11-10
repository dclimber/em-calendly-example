/// A calendar event deletion request that the model refuses. [message] describes the refusal; the model gives no text for
/// it, so the handler ignores the error and the message is for logs only.
sealed class RequestCalendarEventDeletionError implements Exception {
  const RequestCalendarEventDeletionError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `canceling`: the model's transition `request_calendar_deletion` has only that source state.
final class MeetingNotCancelingError extends RequestCalendarEventDeletionError {
  const MeetingNotCancelingError() : super('The meeting is not being canceled.');
}

/// The calendar event deletion of the current cancellation was already requested. The model has no invalid transition
/// for the repeat, so the decider refuses it to keep the request once per cancellation.
final class CalendarEventDeletionAlreadyRequestedError extends RequestCalendarEventDeletionError {
  const CalendarEventDeletionAlreadyRequestedError()
    : super('The calendar event deletion of this cancellation was already requested.');
}
