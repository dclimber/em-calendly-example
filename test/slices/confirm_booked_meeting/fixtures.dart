import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/confirm_booked_meeting/confirm_meeting/command.dart';

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

/// The `calendar_event_requested` event of the meeting, which keeps it pending_calendar.
CalendarEventRequestedEvent requestedEvent({String meetingId = 'meeting-1'}) =>
    CalendarEventRequestedEvent(meetingId: MeetingId(meetingId));

/// The `calendar_event_created` event of the calendar system for the meeting, whose scheduler meeting ref is the
/// meeting id and whose provider event ref is [calendarEventId].
CalendarEventCreatedEvent createdEvent({String meetingId = 'meeting-1', String calendarEventId = 'cal-1'}) =>
    CalendarEventCreatedEvent(
      schedulerMeetingRef: SchedulerMeetingRef(meetingId),
      providerEventRef: calendarEventId,
    );

/// The command that the processor sends for the created event of [meetingId].
ConfirmMeetingCommand commandFor(String meetingId, {String calendarEventId = 'cal-1'}) => ConfirmMeetingCommand(
  meetingId: MeetingId(meetingId),
  calendarEventId: CalendarEventId(calendarEventId),
);
