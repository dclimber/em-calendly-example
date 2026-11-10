/// A cancellation that the model refuses. [message] is the text the model gives, shown to the participant.
sealed class RequestMeetingCancellationError implements Exception {
  const RequestMeetingCancellationError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NotAParticipantError extends RequestMeetingCancellationError {
  const NotAParticipantError() : super('Only the participants of this meeting can change it.');
}

final class MeetingEndedError extends RequestMeetingCancellationError {
  const MeetingEndedError() : super('A meeting that has ended or was canceled cannot be canceled.');
}

final class ChangeInProgressError extends RequestMeetingCancellationError {
  const ChangeInProgressError() : super('Another change to this meeting is still in progress.');
}
