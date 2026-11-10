import '../../../bounded_contexts/meetings/api.dart';

/// Records that the booked slot of a meeting is verified free (`record_booking_slot_verified`). Sent by the processor
/// `booking_free_translator` for a listed free answer.
final class RecordBookingSlotVerifiedCommand {
  const RecordBookingSlotVerifiedCommand({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is RecordBookingSlotVerifiedCommand && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'RecordBookingSlotVerifiedCommand(meetingId: $meetingId)';
}
