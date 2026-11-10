/// A meeting completion that the model refuses. [message] describes the refusal; the model gives no text for it, so the
/// worker ignores the error and the message is for logs only.
sealed class CompleteMeetingError implements Exception {
  const CompleteMeetingError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not `confirmed`: the model's transition `complete` has only that source state.
final class MeetingNotConfirmedError extends CompleteMeetingError {
  const MeetingNotConfirmedError() : super('The meeting is not confirmed.');
}
