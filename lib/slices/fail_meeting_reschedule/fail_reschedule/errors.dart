/// A reschedule failure that the decider refuses. [message] describes the refusal; the model gives no text for it, so the
/// handler ignores the error and the message is for logs only.
sealed class FailRescheduleError implements Exception {
  const FailRescheduleError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `rescheduling`: the model's transition `fail_reschedule` has only that source state. A repeated
/// answer, or an answer after the reschedule completed or failed, lands here.
final class MeetingNotReschedulingError extends FailRescheduleError {
  const MeetingNotReschedulingError() : super('The meeting is not being rescheduled.');
}
