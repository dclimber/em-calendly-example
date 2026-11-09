/// The errors of `edit_meeting_type`.
sealed class EditMeetingTypeError implements Exception {
  const EditMeetingTypeError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Invalid transition `edit_deleted`: the meeting type is deleted. The text is the model's.
final class MeetingTypeDeletedError extends EditMeetingTypeError {
  const MeetingTypeDeletedError() : super('A deleted meeting type cannot be edited.');
}

/// The signed-in employee is not the host of the meeting type, or the meeting type does not exist. The model states no
/// error text for this case (see the gap report).
final class NotMeetingTypeHostError extends EditMeetingTypeError {
  const NotMeetingTypeHostError() : super('Only the host of this meeting type can edit it.');
}
