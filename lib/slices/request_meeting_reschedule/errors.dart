/// A reschedule that the model refuses. [message] is the text the model gives, shown to the participant.
sealed class RequestMeetingRescheduleError implements Exception {
  const RequestMeetingRescheduleError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NotAParticipantError extends RequestMeetingRescheduleError {
  const NotAParticipantError() : super('Only the participants of this meeting can change it.');
}

final class MeetingEndedError extends RequestMeetingRescheduleError {
  const MeetingEndedError() : super('A meeting that has ended or was canceled cannot be rescheduled.');
}

final class ChangeInProgressError extends RequestMeetingRescheduleError {
  const ChangeInProgressError() : super('Another change to this meeting is still in progress.');
}

/// The new slot is held by another meeting of the host, or busy in the host's calendar.
final class SlotUnavailableError extends RequestMeetingRescheduleError {
  const SlotUnavailableError() : super('This time is no longer available. Please choose another slot.');
}

final class CalendarUnverifiedError extends RequestMeetingRescheduleError {
  const CalendarUnverifiedError()
    : super("The host's availability cannot be verified right now. Please try again later.");
}

final class SlotOutsideRulesError extends RequestMeetingRescheduleError {
  const SlotOutsideRulesError() : super("This time is outside the host's booking rules. Please choose another slot.");
}
