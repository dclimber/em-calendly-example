/// A calendar event request that the model refuses. [message] describes the refusal; the model gives no text for it, so
/// the handler ignores the error and the message is for logs only.
sealed class RequestCalendarEventError implements Exception {
  const RequestCalendarEventError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `pending_calendar`: the model's transition `request_calendar_event` has no other source state.
final class MeetingNotPendingCalendarError extends RequestCalendarEventError {
  const MeetingNotPendingCalendarError() : super('The meeting is not waiting for its calendar event.');
}

/// The calendar event of this meeting was already requested. The model has no invalid transition for the repeat, so
/// the decider refuses it to keep the event once per reservation.
final class CalendarEventAlreadyRequestedError extends RequestCalendarEventError {
  const CalendarEventAlreadyRequestedError() : super('The calendar event of this meeting was already requested.');
}
