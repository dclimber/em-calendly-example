/// A calendar event update that the model refuses. [message] describes the refusal; the model gives no text for it, so
/// the handler ignores the error and the message is for logs only.
sealed class RequestCalendarEventUpdateError implements Exception {
  const RequestCalendarEventUpdateError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `rescheduling`: the model's transition `request_calendar_update` has only that source state.
final class MeetingNotReschedulingError extends RequestCalendarEventUpdateError {
  const MeetingNotReschedulingError() : super('The meeting is not being rescheduled.');
}

/// The calendar event update of this reschedule request was already requested. The model has no invalid transition for
/// the repeat, so the decider refuses it to keep the event once per reschedule request.
final class CalendarEventUpdateAlreadyRequestedError extends RequestCalendarEventUpdateError {
  const CalendarEventUpdateAlreadyRequestedError()
    : super('The calendar event update of this reschedule was already requested.');
}
