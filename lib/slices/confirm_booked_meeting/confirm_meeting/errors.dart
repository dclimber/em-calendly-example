/// A confirmation that the decider refuses. [message] describes the refusal; the model gives no text for it, so the
/// handler ignores the error and the message is for logs only.
sealed class ConfirmMeetingError implements Exception {
  const ConfirmMeetingError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `pending_calendar`: the model's transition `confirm` has no other source state. This covers
/// a repeated calendar event, since a confirmed meeting is no longer pending_calendar.
final class MeetingNotAwaitingConfirmationError extends ConfirmMeetingError {
  const MeetingNotAwaitingConfirmationError() : super('The meeting is not waiting for its calendar event.');
}
