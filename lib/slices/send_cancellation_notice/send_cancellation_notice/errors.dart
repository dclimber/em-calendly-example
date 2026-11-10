/// A cancellation notice that the model refuses. [message] describes the refusal; the model gives no text for it, so
/// the handler ignores the error and the message is for logs only.
sealed class SendCancellationNoticeError implements Exception {
  const SendCancellationNoticeError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `canceled`: the model's transition `send_cancellation_notice` has no other source state.
final class MeetingNotCanceledForNoticeError extends SendCancellationNoticeError {
  const MeetingNotCanceledForNoticeError() : super('The meeting is not canceled.');
}

/// The notice was already sent. The model has no invalid transition for the repeat, so the decider refuses it to keep
/// the event once per meeting.
final class CancellationNoticeAlreadySentError extends SendCancellationNoticeError {
  const CancellationNoticeAlreadySentError() : super('The cancellation notice was already sent.');
}
