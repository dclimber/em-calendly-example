/// A slot verification that the decider refuses. [message] describes the refusal; the model gives no text for it, so
/// the handler ignores the error and the message is for logs only.
sealed class RecordBookingSlotVerifiedError implements Exception {
  const RecordBookingSlotVerifiedError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `pending_calendar`: the model's transition `verify_booked_slot` has no other source state.
final class MeetingNotPendingCalendarError extends RecordBookingSlotVerifiedError {
  const MeetingNotPendingCalendarError() : super('The meeting is not waiting for its calendar check.');
}

/// The booked slot of this meeting was already verified. The model has no invalid transition for the repeat, so
/// the decider refuses it to keep the event once per meeting.
final class BookingSlotAlreadyVerifiedError extends RecordBookingSlotVerifiedError {
  const BookingSlotAlreadyVerifiedError() : super('The booked slot of this meeting was already verified.');
}
