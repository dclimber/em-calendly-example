/// A new-slot verification that the decider refuses. [message] describes the refusal; the model gives no text for it,
/// so the handler ignores the error and the message is for logs only.
sealed class RecordNewSlotVerifiedError implements Exception {
  const RecordNewSlotVerifiedError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The meeting is not in `rescheduling`: the model's transition `verify_new_slot` has only that source state.
final class MeetingNotReschedulingError extends RecordNewSlotVerifiedError {
  const MeetingNotReschedulingError() : super('The meeting is not being rescheduled.');
}

/// The new slot of this reschedule request was already verified. The model has no invalid transition for the repeat,
/// so the decider refuses it to keep the event once per reschedule request.
final class NewSlotAlreadyVerifiedError extends RecordNewSlotVerifiedError {
  const NewSlotAlreadyVerifiedError() : super('The new slot of this reschedule was already verified.');
}
