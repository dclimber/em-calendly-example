import '../../../bounded_contexts/meetings/api.dart';

/// Completes the reschedule of a meeting once its calendar event has moved (`complete_reschedule`). Sent by the
/// processor `calendar_updated_translator` for an item of `updated_calendar_events`.
final class CompleteRescheduleCommand {
  const CompleteRescheduleCommand({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is CompleteRescheduleCommand && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'CompleteRescheduleCommand(meetingId: $meetingId)';
}
