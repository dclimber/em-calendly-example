/// The errors of `create_meeting_type`. Each message is the text of the model.
sealed class CreateMeetingTypeError implements Exception {
  const CreateMeetingTypeError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Scenario `schedule_must_exist`: the command names no availability schedule of the host.
final class MeetingTypeScheduleMissingError extends CreateMeetingTypeError {
  const MeetingTypeScheduleMissingError() : super('Choose an availability schedule for this meeting type.');
}
