import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';

/// The `meeting_slot_reserved` event of the examples: Bob books Alice's intro call, with both participants.
MeetingSlotReservedEvent reservedEvent({String meetingId = 'meeting-1'}) => MeetingSlotReservedEvent(
  meetingId: MeetingId(meetingId),
  hostId: HostId('alice-employee-id'),
  bookerId: BookerId('bob-employee-id'),
  meetingTypeId: MeetingTypeId('intro-call-type'),
  meetingTitle: MeetingTitle('Intro call'),
  meetingLocation: MeetingLocation('Room 1'),
  slotStart: SlotStart(DateTime.utc(2027, 3, 15, 9)),
  slotEnd: SlotEnd(DateTime.utc(2027, 3, 15, 9, 30)),
  participants: Participants([
    Participant(
      employeeId: EmployeeId('alice-employee-id'),
      name: EmployeeName('Alice Host'),
      email: EmployeeEmail('alice@example.com'),
      role: 'host',
    ),
    Participant(
      employeeId: EmployeeId('bob-employee-id'),
      name: EmployeeName('Bob Booker'),
      email: EmployeeEmail('bob@example.com'),
      role: 'booker',
    ),
  ]),
);

/// The new time of the reschedule of the examples: 10:00 to 10:30 on 15 March 2027.
final DateTime rescheduleStart = DateTime.utc(2027, 3, 15, 10);
final DateTime rescheduleEnd = DateTime.utc(2027, 3, 15, 10, 30);

/// The `meeting_reschedule_requested` event that holds the new slot of the examples.
MeetingRescheduleRequestedEvent rescheduleRequested({
  String meetingId = 'meeting-1',
  DateTime? start,
  DateTime? end,
}) => MeetingRescheduleRequestedEvent(
  meetingId: MeetingId(meetingId),
  hostId: HostId('alice-employee-id'),
  requestedBy: RequestedBy('bob-employee-id'),
  newSlotStart: NewSlotStart(start ?? rescheduleStart),
  newSlotEnd: NewSlotEnd(end ?? rescheduleEnd),
  calendarEventId: CalendarEventId('calendar-event-1'),
  participants: reservedEvent(meetingId: meetingId).participants,
);

/// The `meeting_rescheduled` event that completes the reschedule.
MeetingRescheduledEvent rescheduled({String meetingId = 'meeting-1'}) =>
    MeetingRescheduledEvent(meetingId: MeetingId(meetingId));

/// The `meeting_moved_in_calendar` event: the calendar moved the meeting to 11:00 to 11:30.
MeetingMovedInCalendarEvent movedInCalendar({String meetingId = 'meeting-1'}) => MeetingMovedInCalendarEvent(
  meetingId: MeetingId(meetingId),
  newSlotStart: NewSlotStart(DateTime.utc(2027, 3, 15, 11)),
  newSlotEnd: NewSlotEnd(DateTime.utc(2027, 3, 15, 11, 30)),
);

/// The `meeting_confirmed` event that the calendar event of [meetingId] confirms.
MeetingConfirmedEvent confirmedEvent({String meetingId = 'meeting-1'}) =>
    MeetingConfirmedEvent(meetingId: MeetingId(meetingId), calendarEventId: CalendarEventId('calendar-event-1'));

/// The `reschedule_notice_sent` event that the decider emits for [meetingId] at [start].
RescheduleNoticeSentEvent noticeSent({String meetingId = 'meeting-1', DateTime? start}) => RescheduleNoticeSentEvent(
  meetingId: MeetingId(meetingId),
  newSlotStart: NewSlotStart(start ?? rescheduleStart),
  participants: reservedEvent(meetingId: meetingId).participants,
);
