import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
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

/// The `meeting_confirmed` event that the booking of [meetingId] records.
MeetingConfirmedEvent confirmedEvent({String meetingId = 'meeting-1'}) =>
    MeetingConfirmedEvent(meetingId: MeetingId(meetingId), calendarEventId: CalendarEventId('cal-1'));

/// The `meeting_reschedule_requested` event of [meetingId] to the new slot starting at [newSlotStart].
MeetingRescheduleRequestedEvent rescheduleRequestedEvent({
  String meetingId = 'meeting-1',
  DateTime? newSlotStart,
  DateTime? newSlotEnd,
}) => MeetingRescheduleRequestedEvent(
  meetingId: MeetingId(meetingId),
  hostId: HostId('alice-employee-id'),
  requestedBy: RequestedBy('bob-employee-id'),
  newSlotStart: NewSlotStart(newSlotStart ?? DateTime.utc(2027, 3, 16, 14)),
  newSlotEnd: NewSlotEnd(newSlotEnd ?? DateTime.utc(2027, 3, 16, 14, 30)),
  calendarEventId: CalendarEventId('cal-1'),
  participants: Participants.empty(),
);

/// The `new_slot_verified` event that the live check of [meetingId] records.
NewSlotVerifiedEvent newSlotVerifiedEvent({String meetingId = 'meeting-1'}) =>
    NewSlotVerifiedEvent(meetingId: MeetingId(meetingId));

/// The `calendar_event_update_requested` event that the decider emits for [meetingId] and [newSlotStart].
CalendarEventUpdateRequestedEvent updateRequestedEvent({
  String meetingId = 'meeting-1',
  DateTime? newSlotStart,
}) => CalendarEventUpdateRequestedEvent(
  meetingId: MeetingId(meetingId),
  newSlotStart: NewSlotStart(newSlotStart ?? DateTime.utc(2027, 3, 16, 14)),
);
