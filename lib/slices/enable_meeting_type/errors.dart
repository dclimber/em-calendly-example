/// The errors of `enable_meeting_type`.
sealed class EnableMeetingTypeError implements Exception {
  const EnableMeetingTypeError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The model's invalid transition `enable_deleted`: a deleted meeting type cannot be enabled.
final class MeetingTypeDeletedCannotBeEnabledError extends EnableMeetingTypeError {
  const MeetingTypeDeletedCannotBeEnabledError() : super('A deleted meeting type cannot be enabled.');
}

/// The signed-in employee is not the host of the meeting type, or the meeting type does not exist. The model states no
/// error text for this case (see the gap report).
final class NotMeetingTypeHostError extends EnableMeetingTypeError {
  const NotMeetingTypeHostError() : super('Only the host of this meeting type can enable it.');
}
