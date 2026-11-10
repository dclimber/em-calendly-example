import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';

/// A requested new time that still needs a live check of the host's calendar.
final class RescheduleAwaitingLiveCheckState {
  const RescheduleAwaitingLiveCheckState({
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
      other is RescheduleAwaitingLiveCheckState &&
      other.meetingId == meetingId &&
      other.hostId == hostId &&
      other.newSlotStart == newSlotStart &&
      other.newSlotEnd == newSlotEnd;

  @override
  int get hashCode => Object.hash(meetingId, hostId, newSlotStart, newSlotEnd);

  @override
  String toString() =>
      'RescheduleAwaitingLiveCheckState(meetingId: $meetingId, hostId: $hostId, '
      'newSlotStart: $newSlotStart, newSlotEnd: $newSlotEnd)';
}
