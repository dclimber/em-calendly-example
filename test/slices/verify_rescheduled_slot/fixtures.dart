import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/verify_rescheduled_slot/record_new_slot_verified/command.dart';

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

/// The `meeting_confirmed` event of the examples.
MeetingConfirmedEvent confirmedEvent({String meetingId = 'meeting-1'}) =>
    MeetingConfirmedEvent(meetingId: MeetingId(meetingId), calendarEventId: CalendarEventId('cal-1'));

/// The `meeting_reschedule_requested` event of the examples: Bob asks to move the meeting to 2027-03-16 at 14:00.
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

/// The `reschedule_availability_check_requested` event that the live check of [requested] emits.
RescheduleAvailabilityCheckRequestedEvent checkRequestedFor(MeetingRescheduleRequestedEvent requested) =>
    RescheduleAvailabilityCheckRequestedEvent(
      meetingId: requested.meetingId,
      hostId: requested.hostId,
      newSlotStart: requested.newSlotStart,
      newSlotEnd: requested.newSlotEnd,
    );

/// The `host_slot_found_free` answer for the meeting, whose scheduler meeting ref is the meeting id.
HostSlotFoundFreeEvent freeAnswer({String meetingId = 'meeting-1'}) =>
    HostSlotFoundFreeEvent(schedulerMeetingRef: SchedulerMeetingRef(meetingId));

/// The command that the processor sends for the free answer of [meetingId].
RecordNewSlotVerifiedCommand commandFor(String meetingId) =>
    RecordNewSlotVerifiedCommand(meetingId: MeetingId(meetingId));
