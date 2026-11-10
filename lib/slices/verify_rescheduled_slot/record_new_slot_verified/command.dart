import '../../../bounded_contexts/meetings/api.dart';

/// Records that the new slot of a reschedule is verified free (`record_new_slot_verified`). Sent by the processor
/// `reschedule_free_translator` for a listed free answer.
final class RecordNewSlotVerifiedCommand {
  const RecordNewSlotVerifiedCommand({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is RecordNewSlotVerifiedCommand && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'RecordNewSlotVerifiedCommand(meetingId: $meetingId)';
}
