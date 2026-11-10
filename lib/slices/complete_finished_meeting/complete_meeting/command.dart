import '../../../bounded_contexts/meetings/api.dart';

/// Marks a confirmed meeting as completed (`complete_meeting`). Sent by the worker `complete_finished_meeting` for each
/// item of `meetings_to_complete` whose end time has passed.
final class CompleteMeetingCommand {
  const CompleteMeetingCommand({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is CompleteMeetingCommand && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'CompleteMeetingCommand(meetingId: $meetingId)';
}
