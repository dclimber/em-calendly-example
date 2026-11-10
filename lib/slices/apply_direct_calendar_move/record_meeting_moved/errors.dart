/// A direct move that the decider refuses. The handler ignores it: the calendar event stays where the calendar put it.
sealed class RecordMeetingMovedError implements Exception {
  const RecordMeetingMovedError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The model's invalid transition `direct_move_during_cancellation`.
final class DirectMoveDuringCancellationError extends RecordMeetingMovedError {
  const DirectMoveDuringCancellationError() : super('A meeting that is being canceled ignores a direct move.');
}

/// The model's invalid transition `direct_move_after_the_end`.
final class DirectMoveAfterTheEndError extends RecordMeetingMovedError {
  const DirectMoveAfterTheEndError() : super('A meeting that has ended or was canceled ignores a direct move.');
}

/// The model gives no transition or invalid transition for a meeting that is not reserved or still pending its calendar
/// event. The text is not from the model: it describes the refusal for logs only (see the lifecycle gaps).
final class MeetingNotConfirmedError extends RecordMeetingMovedError {
  const MeetingNotConfirmedError() : super('A meeting that is not confirmed ignores a direct move.');
}
