import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';

/// A held slot of `reservations_awaiting_calendar_event`. It is listed only once [verified] is true: the calendar
/// system confirmed the slot is free (`booking_slot_verified`). Until then the item is kept but not requested.
final class ReservationAwaitingCalendarEventState {
  const ReservationAwaitingCalendarEventState({
    required this.meetingId,
    required this.hostId,
    required this.meetingTitle,
    required this.meetingLocation,
    required this.slotStart,
    required this.slotEnd,
    required this.participants,
    this.verified = false,
  });

  final MeetingId meetingId;
  final HostId hostId;
  final MeetingTitle meetingTitle;
  final MeetingLocation meetingLocation;
  final SlotStart slotStart;
  final SlotEnd slotEnd;
  final Participants participants;
  final bool verified;

  ReservationAwaitingCalendarEventState copyWith({bool? verified}) => ReservationAwaitingCalendarEventState(
    meetingId: meetingId,
    hostId: hostId,
    meetingTitle: meetingTitle,
    meetingLocation: meetingLocation,
    slotStart: slotStart,
    slotEnd: slotEnd,
    participants: participants,
    verified: verified ?? this.verified,
  );

  @override
  bool operator ==(Object other) =>
      other is ReservationAwaitingCalendarEventState &&
      other.meetingId == meetingId &&
      other.hostId == hostId &&
      other.meetingTitle == meetingTitle &&
      other.meetingLocation == meetingLocation &&
      other.slotStart == slotStart &&
      other.slotEnd == slotEnd &&
      other.participants == participants &&
      other.verified == verified;

  @override
  int get hashCode =>
      Object.hash(meetingId, hostId, meetingTitle, meetingLocation, slotStart, slotEnd, participants, verified);

  @override
  String toString() =>
      'ReservationAwaitingCalendarEventState(meetingId: $meetingId, hostId: $hostId, '
      'meetingTitle: $meetingTitle, meetingLocation: $meetingLocation, slotStart: $slotStart, slotEnd: $slotEnd, '
      'participants: $participants, verified: $verified)';
}
