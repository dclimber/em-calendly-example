/// The errors of `delete_meeting_type`.
sealed class DeleteMeetingTypeError implements Exception {
  const DeleteMeetingTypeError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The signed-in employee is not the host of the meeting type, or the meeting type does not exist. The model states no
/// error text for this case (see the gap report).
final class NotMeetingTypeHostError extends DeleteMeetingTypeError {
  const NotMeetingTypeHostError() : super('Only the host of this meeting type can delete it.');
}
