import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';

/// A held slot that still needs a live check of the host's calendar.
final class ReservationAwaitingLiveCheckState {
  const ReservationAwaitingLiveCheckState({
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
      other is ReservationAwaitingLiveCheckState &&
      other.meetingId == meetingId &&
      other.hostId == hostId &&
      other.slotStart == slotStart &&
      other.slotEnd == slotEnd;

  @override
  int get hashCode => Object.hash(meetingId, hostId, slotStart, slotEnd);

  @override
  String toString() =>
      'ReservationAwaitingLiveCheckState(meetingId: $meetingId, hostId: $hostId, '
      'slotStart: $slotStart, slotEnd: $slotEnd)';
}
