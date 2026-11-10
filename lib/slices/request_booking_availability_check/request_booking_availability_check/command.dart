import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';

/// Asks for a live check of the host's calendar for a held slot (`request_booking_availability_check`). Sent by the
/// processor `booking_check_requester` for an item of `reservations_awaiting_live_check`.
final class RequestBookingAvailabilityCheckCommand {
  const RequestBookingAvailabilityCheckCommand({
    required this.meetingId,
    required this.hostId,
    required this.slotStart,
    required this.slotEnd,
  });

  final MeetingId meetingId;
  final HostId hostId;
  final SlotStart slotStart;
  final SlotEnd slotEnd;

  @override
  bool operator ==(Object other) =>
      other is RequestBookingAvailabilityCheckCommand &&
      other.meetingId == meetingId &&
      other.hostId == hostId &&
      other.slotStart == slotStart &&
      other.slotEnd == slotEnd;

  @override
  int get hashCode => Object.hash(meetingId, hostId, slotStart, slotEnd);

  @override
  String toString() =>
      'RequestBookingAvailabilityCheckCommand(meetingId: $meetingId, hostId: $hostId, '
      'slotStart: $slotStart, slotEnd: $slotEnd)';
}
