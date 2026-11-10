import '../../../bounded_contexts/meetings/api.dart';

/// Completes the cancellation of a meeting once its calendar event is gone (`complete_cancellation`). Sent by the
/// processor `calendar_deleted_translator` for an item of `deleted_calendar_events`.
final class CompleteCancellationCommand {
  const CompleteCancellationCommand({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is CompleteCancellationCommand && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'CompleteCancellationCommand(meetingId: $meetingId)';
}
