/// A direct deletion that the decider refuses. The handler ignores it: the meeting keeps its state.
sealed class RecordMeetingDeletedError implements Exception {
  const RecordMeetingDeletedError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The model's invalid transition `direct_deletion_after_the_end`.
final class DirectDeletionAfterTheEndError extends RecordMeetingDeletedError {
  const DirectDeletionAfterTheEndError() : super('A meeting that has ended or was canceled ignores a direct deletion.');
}

/// The model gives no transition or invalid transition for a meeting that is not reserved or still pending its calendar
/// event. The text is not from the model: it describes the refusal for logs only (see the lifecycle gaps).
final class MeetingNotDeletableError extends RecordMeetingDeletedError {
  const MeetingNotDeletableError() : super('A meeting that is not confirmed ignores a direct deletion.');
}
