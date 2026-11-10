/// A booking confirmation that the model refuses. [message] describes the refusal; the model gives no text for it, so
/// the handler ignores the error and the message is for logs only.
sealed class SendBookingConfirmationError implements Exception {
  const SendBookingConfirmationError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `confirmed`: the model's transition `send_booking_confirmation` has no other source state.
final class MeetingNotConfirmedError extends SendBookingConfirmationError {
  const MeetingNotConfirmedError() : super('The meeting is not confirmed.');
}

/// The booking confirmation of this meeting was already sent. The model has no invalid transition for the repeat, so
/// the decider refuses it to keep the event once per meeting.
final class BookingConfirmationAlreadySentError extends SendBookingConfirmationError {
  const BookingConfirmationAlreadySentError() : super('The booking confirmation of this meeting was already sent.');
}
