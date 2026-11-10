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
  participants: _participants,
);

final _participants = Participants([
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
]);

/// The `meeting_confirmed` event that the calendar check of [meetingId] records, with its calendar event.
MeetingConfirmedEvent confirmedEvent({String meetingId = 'meeting-1'}) =>
    MeetingConfirmedEvent(meetingId: MeetingId(meetingId), calendarEventId: CalendarEventId('evt-1'));

/// The `meeting_cancellation_requested` event that Bob requests for [meetingId].
MeetingCancellationRequestedEvent cancellationRequestedEvent({String meetingId = 'meeting-1'}) =>
    MeetingCancellationRequestedEvent(
      meetingId: MeetingId(meetingId),
      hostId: HostId('alice-employee-id'),
      requestedBy: RequestedBy('bob-employee-id'),
      calendarEventId: CalendarEventId('evt-1'),
      participants: _participants,
    );

/// The `calendar_event_deletion_requested` event that the decider emits for [meetingId].
CalendarEventDeletionRequestedEvent deletionRequestedEvent({String meetingId = 'meeting-1'}) =>
    CalendarEventDeletionRequestedEvent(meetingId: MeetingId(meetingId));

/// The `meeting_canceled` event of [meetingId]: the calendar event is already gone.
MeetingCanceledEvent canceledEvent({String meetingId = 'meeting-1'}) =>
    MeetingCanceledEvent(meetingId: MeetingId(meetingId));

/// The `meeting_cancellation_failed` event of [meetingId]: the meeting stays confirmed.
MeetingCancellationFailedEvent cancellationFailedEvent({String meetingId = 'meeting-1'}) =>
    MeetingCancellationFailedEvent(meetingId: MeetingId(meetingId), failureReason: FailureReason('calendar busy'));
