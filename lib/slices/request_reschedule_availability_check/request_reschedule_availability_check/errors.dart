/// A live check that the model refuses. [message] describes the refusal; the model gives no text for it, so the
/// handler ignores the error and the message is for logs only.
sealed class RequestRescheduleAvailabilityCheckError implements Exception {
  const RequestRescheduleAvailabilityCheckError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `rescheduling`: the model's transition `request_reschedule_check` has only that source state.
final class MeetingNotReschedulingError extends RequestRescheduleAvailabilityCheckError {
  const MeetingNotReschedulingError() : super('The meeting is not being rescheduled.');
}

/// The live check of this reschedule was already requested. The model has no invalid transition for the repeat, so
/// the decider refuses it to keep the event once per requested new time.
final class RescheduleAvailabilityCheckAlreadyRequestedError extends RequestRescheduleAvailabilityCheckError {
  const RescheduleAvailabilityCheckAlreadyRequestedError()
    : super('The calendar check of this reschedule was already requested.');
}
