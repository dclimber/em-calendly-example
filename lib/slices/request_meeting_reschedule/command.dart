import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';

/// The `request_meeting_reschedule` command. [hostId], [meetingTypeId], and [scheduleId] come from the meeting's
/// `meeting_slot_reserved` and its meeting type's history, read before the decision; [now] is the current time from
/// `services.clock.now()`.
final class RequestMeetingRescheduleCommand {
  const RequestMeetingRescheduleCommand({
    required this.meetingId,
    required this.hostId,
    required this.meetingTypeId,
    required this.scheduleId,
    required this.requestedBy,
    required this.newSlotStart,
    required this.newSlotEnd,
    required this.now,
  });

  final MeetingId meetingId;
  final HostId hostId;
  final MeetingTypeId meetingTypeId;
  final ScheduleId scheduleId;
  final RequestedBy requestedBy;

  /// UTC instants: the requested slot is `[newSlotStart, newSlotEnd)`.
  final DateTime newSlotStart;
  final DateTime newSlotEnd;
  final DateTime now;
}
