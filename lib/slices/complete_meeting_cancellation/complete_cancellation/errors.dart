/// A cancellation completion that the decider refuses. [message] describes the refusal; the model gives no text for it, so
/// the handler ignores the error and the message is for logs only.
sealed class CompleteCancellationError implements Exception {
  const CompleteCancellationError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `canceling`: the model's transition `complete_cancellation` has only that source state. This
/// covers a repeated calendar event, since a completed cancellation leaves the meeting canceled.
final class MeetingNotCancelingError extends CompleteCancellationError {
  const MeetingNotCancelingError() : super('The meeting is not being canceled.');
}
