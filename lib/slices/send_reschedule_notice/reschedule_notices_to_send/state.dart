import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';

/// A meeting of `reschedule_notices_to_send`, keyed by its meeting id. It is listed for its announcement only while
/// [ready] is true: a completed reschedule (`meeting_rescheduled`) or a direct move (`meeting_moved_in_calendar`) made
/// it ready, and `reschedule_notice_sent` clears it again. The item is kept between announcements, so the next
/// reschedule still has its title.
final class RescheduleNoticeToSendState {
  const RescheduleNoticeToSendState({
    required this.meetingId,
    required this.meetingTitle,
    required this.newSlotStart,
    required this.newSlotEnd,
    required this.participants,
    this.ready = false,
  });

  final MeetingId meetingId;

  /// Null until `meeting_slot_reserved` is seen. A reschedule can be folded before the reservation in a partial history.
  final MeetingTitle? meetingTitle;
  final NewSlotStart newSlotStart;
  final NewSlotEnd newSlotEnd;
  final Participants participants;
  final bool ready;

  RescheduleNoticeToSendState copyWith({
    MeetingTitle? meetingTitle,
    NewSlotStart? newSlotStart,
    NewSlotEnd? newSlotEnd,
    Participants? participants,
    bool? ready,
  }) => RescheduleNoticeToSendState(
    meetingId: meetingId,
    meetingTitle: meetingTitle ?? this.meetingTitle,
    newSlotStart: newSlotStart ?? this.newSlotStart,
    newSlotEnd: newSlotEnd ?? this.newSlotEnd,
    participants: participants ?? this.participants,
    ready: ready ?? this.ready,
  );

  @override
  bool operator ==(Object other) =>
      other is RescheduleNoticeToSendState &&
      other.meetingId == meetingId &&
      other.meetingTitle == meetingTitle &&
      other.newSlotStart == newSlotStart &&
      other.newSlotEnd == newSlotEnd &&
      other.participants == participants &&
      other.ready == ready;

  @override
  int get hashCode => Object.hash(meetingId, meetingTitle, newSlotStart, newSlotEnd, participants, ready);

  @override
  String toString() =>
      'RescheduleNoticeToSendState(meetingId: $meetingId, meetingTitle: $meetingTitle, '
      'newSlotStart: $newSlotStart, newSlotEnd: $newSlotEnd, participants: $participants, ready: $ready)';
}
