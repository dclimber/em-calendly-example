import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_meeting_reschedule/fail_reschedule/command.dart';

/// The `meeting_slot_reserved` event of the examples: Bob books Alice's intro call.
MeetingSlotReservedEvent reservedEvent({String meetingId = 'meeting-1'}) => MeetingSlotReservedEvent(
  meetingId: MeetingId(meetingId),
  hostId: HostId('alice-employee-id'),
  bookerId: BookerId('bob-employee-id'),
  meetingTypeId: MeetingTypeId('intro-call-type'),
  meetingTitle: MeetingTitle('Intro call'),
  meetingLocation: MeetingLocation('Room 1'),
  slotStart: SlotStart(DateTime.utc(2027, 3, 15, 9)),
  slotEnd: SlotEnd(DateTime.utc(2027, 3, 15, 9, 30)),
  participants: Participants.empty(),
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
      newSlotStart: NewSlotStart(DateTime.utc(2027, 3, 16, 14)),
      newSlotEnd: NewSlotEnd(DateTime.utc(2027, 3, 16, 14, 30)),
      calendarEventId: CalendarEventId('cal-1'),
      participants: Participants.empty(),
    );

/// The `reschedule_availability_check_requested` event of [meetingId], which opens the live check of the new slot.
RescheduleAvailabilityCheckRequestedEvent rescheduleCheckRequestedEvent({String meetingId = 'meeting-1'}) =>
    RescheduleAvailabilityCheckRequestedEvent(
      meetingId: MeetingId(meetingId),
      hostId: HostId('alice-employee-id'),
      newSlotStart: NewSlotStart(DateTime.utc(2027, 3, 16, 14)),
      newSlotEnd: NewSlotEnd(DateTime.utc(2027, 3, 16, 14, 30)),
    );

/// The `calendar_event_update_failed` answer for [meetingId], with the failure code of the calendar system.
CalendarEventUpdateFailedEvent updateFailedAnswer({String meetingId = 'meeting-1', String code = 'refused'}) =>
    CalendarEventUpdateFailedEvent(failureCode: FailureCode(code), schedulerMeetingRef: SchedulerMeetingRef(meetingId));

/// The `host_slot_found_busy` answer for [meetingId].
HostSlotFoundBusyEvent busyAnswer({String meetingId = 'meeting-1'}) =>
    HostSlotFoundBusyEvent(schedulerMeetingRef: SchedulerMeetingRef(meetingId));

/// The `availability_check_failed` answer for [meetingId].
AvailabilityCheckFailedEvent availabilityFailedAnswer({String meetingId = 'meeting-1'}) => AvailabilityCheckFailedEvent(
  failureCode: FailureCode('timeout'),
  schedulerMeetingRef: SchedulerMeetingRef(meetingId),
);

/// The command that the processor sends for a negative answer of [meetingId].
FailRescheduleCommand commandFor(String meetingId, String reason) =>
    FailRescheduleCommand(meetingId: MeetingId(meetingId), failureReason: FailureReason(reason));
