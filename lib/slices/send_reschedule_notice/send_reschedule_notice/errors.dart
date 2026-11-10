/// A reschedule notice that the model refuses. [message] describes the refusal; the model gives no text for it, so
/// the handler ignores the error and the message is for logs only.
sealed class SendRescheduleNoticeError implements Exception {
  const SendRescheduleNoticeError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `confirmed`: the model's transition `send_reschedule_notice` has no other source state.
final class MeetingNotConfirmedForNoticeError extends SendRescheduleNoticeError {
  const MeetingNotConfirmedForNoticeError() : super('The meeting is not confirmed.');
}

/// The notice for this new time was already sent. The model has no invalid transition for the repeat, so the decider
/// refuses it to keep the event once per new time.
final class RescheduleNoticeAlreadySentError extends SendRescheduleNoticeError {
  const RescheduleNoticeAlreadySentError() : super('The reschedule notice for this new time was already sent.');
}
