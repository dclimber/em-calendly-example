import '../../bounded_contexts/employee_directory/api.dart';
import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';

/// The `reserve_meeting_slot` command. Every field is either a form input or generated before the decision, so the
/// decider stays pure. [hostId] and [scheduleId] come from the meeting type's history, read before the decision.
final class ReserveMeetingSlotCommand {
  const ReserveMeetingSlotCommand({
    required this.meetingId,
    required this.meetingTypeId,
    required this.hostId,
    required this.scheduleId,
    required this.bookerId,
    required this.bookerName,
    required this.bookerEmail,
    required this.slotStart,
    required this.slotEnd,
    required this.now,
  });

  final MeetingId meetingId;
  final MeetingTypeId meetingTypeId;
  final HostId hostId;
  final ScheduleId scheduleId;
  final BookerId bookerId;
  final EmployeeName bookerName;
  final EmployeeEmail bookerEmail;

  /// UTC instants: the slot is `[slotStart, slotEnd)`.
  final DateTime slotStart;
  final DateTime slotEnd;

  /// The current time from `services.clock.now()`.
  final DateTime now;
}
