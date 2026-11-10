/// A booking failure that the decider refuses. [message] describes the refusal; the model gives no text for it, so the
/// handler ignores the error and the message is for logs only.
sealed class FailBookingError implements Exception {
  const FailBookingError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `pending_calendar`: the model's transition `fail_booking` has no other source state, and the
/// model gives no invalid transition for this command. A repeated answer, or an answer after a confirmation, lands here.
final class BookingNotPendingCalendarError extends FailBookingError {
  const BookingNotPendingCalendarError() : super('The meeting is not waiting for its calendar check.');
}
