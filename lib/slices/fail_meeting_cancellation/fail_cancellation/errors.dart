/// A cancellation failure that the decider refuses. [message] describes the refusal; the model gives no text for it, so the
/// handler ignores the error and the message is for logs only.
sealed class FailCancellationError implements Exception {
  const FailCancellationError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `canceling`: the model's transition `fail_cancellation` has only that source state. A repeated
/// answer, or an answer after the cancellation completed or failed, lands here.
final class MeetingNotCancelingError extends FailCancellationError {
  const MeetingNotCancelingError() : super('The meeting is not being canceled.');
}
