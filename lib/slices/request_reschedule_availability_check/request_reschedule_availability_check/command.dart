import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';

/// Asks for a live check of the host's calendar for a requested new time (`request_reschedule_availability_check`).
/// Sent by the processor `reschedule_check_requester` for an item of `reschedules_awaiting_live_check`.
final class RequestRescheduleAvailabilityCheckCommand {
  const RequestRescheduleAvailabilityCheckCommand({
    required this.meetingId,
    required this.hostId,
    required this.newSlotStart,
    required this.newSlotEnd,
  });

  final MeetingId meetingId;
  final HostId hostId;
  final NewSlotStart newSlotStart;
  final NewSlotEnd newSlotEnd;

  @override
  bool operator ==(Object other) =>
      other is RequestRescheduleAvailabilityCheckCommand &&
      other.meetingId == meetingId &&
      other.hostId == hostId &&
      other.newSlotStart == newSlotStart &&
      other.newSlotEnd == newSlotEnd;

  @override
  int get hashCode => Object.hash(meetingId, hostId, newSlotStart, newSlotEnd);

  @override
  String toString() =>
      'RequestRescheduleAvailabilityCheckCommand(meetingId: $meetingId, hostId: $hostId, '
      'newSlotStart: $newSlotStart, newSlotEnd: $newSlotEnd)';
}
