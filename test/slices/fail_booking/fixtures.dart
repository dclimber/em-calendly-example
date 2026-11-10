import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_booking/fail_booking/command.dart';

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

/// The `host_slot_found_busy` answer for the meeting, whose scheduler meeting ref is the meeting id.
HostSlotFoundBusyEvent busyAnswer({String meetingId = 'meeting-1'}) =>
    HostSlotFoundBusyEvent(schedulerMeetingRef: SchedulerMeetingRef(meetingId));

/// The `availability_check_failed` answer for the meeting.
AvailabilityCheckFailedEvent availabilityFailedAnswer({String meetingId = 'meeting-1'}) => AvailabilityCheckFailedEvent(
  failureCode: FailureCode('timeout'),
  schedulerMeetingRef: SchedulerMeetingRef(meetingId),
);

/// The `calendar_event_creation_failed` answer for the meeting, with the failure code of the calendar system.
CalendarEventCreationFailedEvent creationFailedAnswer({String meetingId = 'meeting-1', String code = 'refused'}) =>
    CalendarEventCreationFailedEvent(
      failureCode: FailureCode(code),
      schedulerMeetingRef: SchedulerMeetingRef(meetingId),
    );

/// The command that the processor sends for a negative answer of [meetingId].
FailBookingCommand commandFor(String meetingId, String reason) =>
    FailBookingCommand(meetingId: MeetingId(meetingId), failureReason: FailureReason(reason));
