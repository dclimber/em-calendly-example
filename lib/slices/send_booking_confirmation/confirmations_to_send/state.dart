import '../../../bounded_contexts/meetings/api.dart';
import '../../../bounded_contexts/host_setup/api.dart';

/// A confirmed meeting of `confirmations_to_send`. It is listed for its announcement only once [ready] is true: the
/// meeting was confirmed (`meeting_confirmed`). Until then the item is kept but not announced.
final class ConfirmationToSendState {
  const ConfirmationToSendState({
    required this.meetingId,
    required this.meetingTitle,
    required this.meetingLocation,
    required this.slotStart,
    required this.slotEnd,
    required this.participants,
    this.ready = false,
  });

  final MeetingId meetingId;
  final MeetingTitle meetingTitle;
  final MeetingLocation meetingLocation;
  final SlotStart slotStart;
  final SlotEnd slotEnd;
  final Participants participants;
  final bool ready;

  ConfirmationToSendState copyWith({bool? ready}) => ConfirmationToSendState(
    meetingId: meetingId,
    meetingTitle: meetingTitle,
    meetingLocation: meetingLocation,
    slotStart: slotStart,
    slotEnd: slotEnd,
    participants: participants,
    ready: ready ?? this.ready,
  );

  @override
  bool operator ==(Object other) =>
      other is ConfirmationToSendState &&
      other.meetingId == meetingId &&
      other.meetingTitle == meetingTitle &&
      other.meetingLocation == meetingLocation &&
      other.slotStart == slotStart &&
      other.slotEnd == slotEnd &&
      other.participants == participants &&
      other.ready == ready;

  @override
  int get hashCode => Object.hash(meetingId, meetingTitle, meetingLocation, slotStart, slotEnd, participants, ready);

  @override
  String toString() =>
      'ConfirmationToSendState(meetingId: $meetingId, meetingTitle: $meetingTitle, '
      'meetingLocation: $meetingLocation, slotStart: $slotStart, slotEnd: $slotEnd, '
      'participants: $participants, ready: $ready)';
}
