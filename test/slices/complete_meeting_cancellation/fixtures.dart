import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
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

/// The `meeting_confirmed` event that the booking of [meetingId] records.
MeetingConfirmedEvent confirmedEvent({String meetingId = 'meeting-1'}) =>
    MeetingConfirmedEvent(meetingId: MeetingId(meetingId), calendarEventId: CalendarEventId('cal-1'));

/// The `meeting_cancellation_requested` event of [meetingId], which moves a confirmed meeting to canceling.
MeetingCancellationRequestedEvent cancellationRequestedEvent({String meetingId = 'meeting-1'}) =>
    MeetingCancellationRequestedEvent(
      meetingId: MeetingId(meetingId),
      hostId: HostId('alice-employee-id'),
      requestedBy: RequestedBy('alice-employee-id'),
      calendarEventId: CalendarEventId('cal-1'),
      participants: Participants.empty(),
    );

/// The `calendar_event_deletion_requested` event that the decider of the previous slice emits for [meetingId].
CalendarEventDeletionRequestedEvent deletionRequestedEvent({String meetingId = 'meeting-1'}) =>
    CalendarEventDeletionRequestedEvent(meetingId: MeetingId(meetingId));

/// The `meeting_cancellation_failed` event of [meetingId], which returns a canceling meeting to confirmed.
MeetingCancellationFailedEvent cancellationFailedEvent({String meetingId = 'meeting-1'}) =>
    MeetingCancellationFailedEvent(
      meetingId: MeetingId(meetingId),
      failureReason: FailureReason('calendar unavailable'),
    );

/// The `meeting_canceled` event that the decider emits for [meetingId].
MeetingCanceledEvent canceledEvent({String meetingId = 'meeting-1'}) =>
    MeetingCanceledEvent(meetingId: MeetingId(meetingId));

/// The `calendar_event_deleted` event of the calendar system for the meeting, whose scheduler meeting ref is [meetingId].
CalendarEventDeletedEvent calendarEventDeleted({String meetingId = 'meeting-1'}) =>
    CalendarEventDeletedEvent(schedulerMeetingRef: SchedulerMeetingRef(meetingId));
