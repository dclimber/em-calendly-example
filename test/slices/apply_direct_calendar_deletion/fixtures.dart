import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_deletion/record_meeting_deleted/command.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_deletion/record_meeting_deleted/state.dart';

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

/// The `meeting_reschedule_requested` event of [meetingId], which moves a confirmed meeting to rescheduling.
MeetingRescheduleRequestedEvent rescheduleRequestedEvent({String meetingId = 'meeting-1'}) =>
    MeetingRescheduleRequestedEvent(
      meetingId: MeetingId(meetingId),
      hostId: HostId('alice-employee-id'),
      requestedBy: RequestedBy('bob-employee-id'),
      newSlotStart: NewSlotStart(DateTime.utc(2027, 3, 16, 10)),
      newSlotEnd: NewSlotEnd(DateTime.utc(2027, 3, 16, 10, 30)),
      calendarEventId: CalendarEventId('cal-1'),
      participants: Participants.empty(),
    );

/// The `meeting_cancellation_requested` event of [meetingId], which moves a confirmed meeting to canceling.
MeetingCancellationRequestedEvent cancellationRequestedEvent({String meetingId = 'meeting-1'}) =>
    MeetingCancellationRequestedEvent(
      meetingId: MeetingId(meetingId),
      hostId: HostId('alice-employee-id'),
      requestedBy: RequestedBy('alice-employee-id'),
      calendarEventId: CalendarEventId('cal-1'),
      participants: Participants.empty(),
    );

/// The `meeting_canceled` event of [meetingId].
MeetingCanceledEvent canceledEvent({String meetingId = 'meeting-1'}) =>
    MeetingCanceledEvent(meetingId: MeetingId(meetingId));

/// The `meeting_completed` event of [meetingId].
MeetingCompletedEvent completedEvent({String meetingId = 'meeting-1'}) =>
    MeetingCompletedEvent(meetingId: MeetingId(meetingId));

/// The `meeting_booking_failed` event of [meetingId].
MeetingBookingFailedEvent bookingFailedEvent({String meetingId = 'meeting-1'}) =>
    MeetingBookingFailedEvent(meetingId: MeetingId(meetingId), failureReason: FailureReason('busy'));

/// The `calendar_event_deleted_directly` event of the calendar system for the meeting [meetingId].
CalendarEventDeletedDirectlyEvent deletedDirectly({String meetingId = 'meeting-1'}) =>
    CalendarEventDeletedDirectlyEvent(schedulerMeetingRef: SchedulerMeetingRef(meetingId));

/// The `record_meeting_deleted` command for [meetingId].
RecordMeetingDeletedCommand deleteCommand({String meetingId = 'meeting-1'}) =>
    RecordMeetingDeletedCommand(meetingId: MeetingId(meetingId));

/// The lifecycle that the decider and the processor fold from [events].
RecordMeetingDeletedState lifecycleOf(Iterable<MeetingsEvent> events) =>
    events.fold(meetingLifecycleView.initialState, meetingLifecycleView.evolve);
