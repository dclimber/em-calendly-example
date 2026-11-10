import '../../../bounded_contexts/meetings/api.dart';

/// A meeting whose host is free for the slot, as the answer of the live check says.
final class FreeAnswerForBookingState {
  const FreeAnswerForBookingState({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is FreeAnswerForBookingState && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'FreeAnswerForBookingState(meetingId: $meetingId)';
}
