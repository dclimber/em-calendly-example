import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';

/// The end of the examples' meeting: 09:30 on 15 March 2027, UTC.
final meetingEnd = DateTime.utc(2027, 3, 15, 9, 30);

/// The `meeting_slot_reserved` event of the examples, which ends at [slotEnd].
MeetingSlotReservedEvent reservedEvent({String meetingId = 'meeting-1', DateTime? slotEnd}) => MeetingSlotReservedEvent(
  meetingId: MeetingId(meetingId),
  hostId: HostId('alice-employee-id'),
  bookerId: BookerId('bob-employee-id'),
  meetingTypeId: MeetingTypeId('intro-call-type'),
  meetingTitle: MeetingTitle('Intro call'),
  meetingLocation: MeetingLocation('Room 1'),
  slotStart: SlotStart((slotEnd ?? meetingEnd).subtract(const Duration(minutes: 30))),
  slotEnd: SlotEnd(slotEnd ?? meetingEnd),
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

/// The `meeting_confirmed` event of [meetingId].
MeetingConfirmedEvent confirmedEvent({String meetingId = 'meeting-1'}) =>
    MeetingConfirmedEvent(meetingId: MeetingId(meetingId), calendarEventId: CalendarEventId('evt-1'));

/// The `meeting_reschedule_requested` event of [meetingId], which moves the end to [newSlotEnd].
MeetingRescheduleRequestedEvent rescheduleRequestedEvent({
  String meetingId = 'meeting-1',
  required DateTime newSlotEnd,
}) => MeetingRescheduleRequestedEvent(
  meetingId: MeetingId(meetingId),
  hostId: HostId('alice-employee-id'),
  requestedBy: RequestedBy('bob-employee-id'),
  newSlotStart: NewSlotStart(newSlotEnd.subtract(const Duration(minutes: 30))),
  newSlotEnd: NewSlotEnd(newSlotEnd),
  calendarEventId: CalendarEventId('evt-1'),
  participants: _participants,
);

/// The `meeting_rescheduled` event of [meetingId]: the completed reschedule.
MeetingRescheduledEvent rescheduledEvent({String meetingId = 'meeting-1'}) =>
    MeetingRescheduledEvent(meetingId: MeetingId(meetingId));

/// The `meeting_moved_in_calendar` event of [meetingId], which moves the meeting to [newSlotEnd].
MeetingMovedInCalendarEvent movedInCalendarEvent({String meetingId = 'meeting-1', required DateTime newSlotEnd}) =>
    MeetingMovedInCalendarEvent(
      meetingId: MeetingId(meetingId),
      newSlotStart: NewSlotStart(newSlotEnd.subtract(const Duration(minutes: 30))),
      newSlotEnd: NewSlotEnd(newSlotEnd),
    );

/// The `meeting_cancellation_requested` event of [meetingId].
MeetingCancellationRequestedEvent cancellationRequestedEvent({String meetingId = 'meeting-1'}) =>
    MeetingCancellationRequestedEvent(
      meetingId: MeetingId(meetingId),
      hostId: HostId('alice-employee-id'),
      requestedBy: RequestedBy('bob-employee-id'),
      calendarEventId: CalendarEventId('evt-1'),
      participants: _participants,
    );

/// The `meeting_canceled` event of [meetingId].
MeetingCanceledEvent canceledEvent({String meetingId = 'meeting-1'}) =>
    MeetingCanceledEvent(meetingId: MeetingId(meetingId));

/// The `meeting_completed` event of [meetingId].
MeetingCompletedEvent completedEvent({String meetingId = 'meeting-1'}) =>
    MeetingCompletedEvent(meetingId: MeetingId(meetingId));

/// The `meeting_booking_failed` event of [meetingId].
MeetingBookingFailedEvent bookingFailedEvent({String meetingId = 'meeting-1'}) =>
    MeetingBookingFailedEvent(meetingId: MeetingId(meetingId), failureReason: FailureReason('calendar busy'));

/// The `meeting_reschedule_failed` event of [meetingId]: the meeting stays confirmed.
MeetingRescheduleFailedEvent rescheduleFailedEvent({String meetingId = 'meeting-1'}) =>
    MeetingRescheduleFailedEvent(meetingId: MeetingId(meetingId), failureReason: FailureReason('calendar busy'));

/// The `meeting_cancellation_failed` event of [meetingId]: the meeting stays confirmed.
MeetingCancellationFailedEvent cancellationFailedEvent({String meetingId = 'meeting-1'}) =>
    MeetingCancellationFailedEvent(meetingId: MeetingId(meetingId), failureReason: FailureReason('calendar busy'));
