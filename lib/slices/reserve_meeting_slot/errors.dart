/// A booking that the model refuses. [message] is the text the model gives, shown to the booker.
sealed class ReserveMeetingSlotError implements Exception {
  const ReserveMeetingSlotError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class MeetingTypeNotAcceptingError extends ReserveMeetingSlotError {
  const MeetingTypeNotAcceptingError() : super('This meeting type is not accepting bookings.');
}

final class SelfBookingError extends ReserveMeetingSlotError {
  const SelfBookingError() : super('You cannot book a meeting with yourself.');
}

final class SlotHeldError extends ReserveMeetingSlotError {
  const SlotHeldError() : super('This time was just booked. Please choose another slot.');
}

final class CalendarUnverifiedError extends ReserveMeetingSlotError {
  const CalendarUnverifiedError()
    : super("The host's availability cannot be verified right now. Please try again later.");
}

final class SlotBusyError extends ReserveMeetingSlotError {
  const SlotBusyError() : super('This time is no longer available. Please choose another slot.');
}

final class SlotOutsideRulesError extends ReserveMeetingSlotError {
  const SlotOutsideRulesError() : super("This time is outside the host's booking rules. Please choose another slot.");
}
