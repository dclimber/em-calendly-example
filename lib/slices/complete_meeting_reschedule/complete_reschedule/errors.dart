/// A reschedule completion that the decider refuses. [message] describes the refusal; the model gives no text for it, so
/// the handler ignores the error and the message is for logs only.
sealed class CompleteRescheduleError implements Exception {
  const CompleteRescheduleError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `rescheduling`: the model's transition `complete_reschedule` has only that source state. This
/// covers a repeated calendar event, since a completed reschedule leaves the meeting confirmed.
final class MeetingNotReschedulingError extends CompleteRescheduleError {
  const MeetingNotReschedulingError() : super('The meeting is not being rescheduled.');
}
