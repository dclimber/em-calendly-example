import '../../../bounded_contexts/meetings/api.dart';

/// A meeting whose host is free for the requested new slot, as the answer of the live check says.
final class FreeAnswerForRescheduleState {
  const FreeAnswerForRescheduleState({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is FreeAnswerForRescheduleState && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'FreeAnswerForRescheduleState(meetingId: $meetingId)';
}
