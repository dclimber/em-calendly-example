import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_meeting_cancellation/fail_cancellation/command.dart';

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

/// The `meeting_cancellation_requested` event of [meetingId], which moves a confirmed meeting to canceling.
MeetingCancellationRequestedEvent cancellationRequestedEvent({String meetingId = 'meeting-1'}) =>
    MeetingCancellationRequestedEvent(
      meetingId: MeetingId(meetingId),
      hostId: HostId('alice-employee-id'),
      requestedBy: RequestedBy('bob-employee-id'),
      calendarEventId: CalendarEventId('cal-1'),
      participants: Participants.empty(),
    );

/// The `calendar_event_deletion_failed` answer for [meetingId], with the failure code of the calendar system.
CalendarEventDeletionFailedEvent deletionFailedAnswer({String meetingId = 'meeting-1', String code = 'refused'}) =>
    CalendarEventDeletionFailedEvent(
      failureCode: FailureCode(code),
      schedulerMeetingRef: SchedulerMeetingRef(meetingId),
    );

/// The command that the processor sends for a failed deletion of [meetingId].
FailCancellationCommand commandFor(String meetingId, String reason) =>
    FailCancellationCommand(meetingId: MeetingId(meetingId), failureReason: FailureReason(reason));
