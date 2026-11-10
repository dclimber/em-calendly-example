import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';

/// A meeting of `cancellation_notices_to_send`, keyed by its meeting id. It is listed for its announcement only while
/// [ready] is true: `meeting_canceled` made it ready, and `cancellation_notice_sent` clears it again. The item keeps the
/// title and the slot of the reservation, which the notice needs.
final class CancellationNoticeToSendState {
  const CancellationNoticeToSendState({
    required this.meetingId,
    required this.meetingTitle,
    required this.slotStart,
    required this.slotEnd,
    required this.participants,
    this.ready = false,
  });

  final MeetingId meetingId;
  final MeetingTitle meetingTitle;
  final SlotStart slotStart;
  final SlotEnd slotEnd;
  final Participants participants;
  final bool ready;

  CancellationNoticeToSendState copyWith({Participants? participants, bool? ready}) => CancellationNoticeToSendState(
    meetingId: meetingId,
    meetingTitle: meetingTitle,
    slotStart: slotStart,
    slotEnd: slotEnd,
    participants: participants ?? this.participants,
    ready: ready ?? this.ready,
  );

  @override
  bool operator ==(Object other) =>
      other is CancellationNoticeToSendState &&
      other.meetingId == meetingId &&
      other.meetingTitle == meetingTitle &&
      other.slotStart == slotStart &&
      other.slotEnd == slotEnd &&
      other.participants == participants &&
      other.ready == ready;

  @override
  int get hashCode => Object.hash(meetingId, meetingTitle, slotStart, slotEnd, participants, ready);

  @override
  String toString() =>
      'CancellationNoticeToSendState(meetingId: $meetingId, meetingTitle: $meetingTitle, '
      'slotStart: $slotStart, slotEnd: $slotEnd, participants: $participants, ready: $ready)';
}
