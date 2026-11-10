/// A live check that the model refuses. [message] describes the refusal; the model gives no text for it, so the
/// handler ignores the error and the message is for logs only.
sealed class RequestBookingAvailabilityCheckError implements Exception {
  const RequestBookingAvailabilityCheckError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `pending_calendar`: the model's transition `request_booking_check` has no other source state.
final class MeetingNotPendingCalendarError extends RequestBookingAvailabilityCheckError {
  const MeetingNotPendingCalendarError() : super('The meeting is not waiting for its calendar check.');
}

/// The live check of this meeting was already requested. The model has no invalid transition for the repeat, so
/// the decider refuses it to keep the event once per held slot.
final class AvailabilityCheckAlreadyRequestedError extends RequestBookingAvailabilityCheckError {
  const AvailabilityCheckAlreadyRequestedError() : super('The calendar check of this meeting was already requested.');
}
