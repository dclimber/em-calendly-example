import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/verify_booked_slot/record_booking_slot_verified/command.dart';

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

/// The `host_slot_found_free` answer for the meeting, whose scheduler meeting ref is the meeting id.
HostSlotFoundFreeEvent freeAnswer({String meetingId = 'meeting-1'}) =>
    HostSlotFoundFreeEvent(schedulerMeetingRef: SchedulerMeetingRef(meetingId));

/// The command that the processor sends for the free answer of [meetingId].
RecordBookingSlotVerifiedCommand commandFor(String meetingId) =>
    RecordBookingSlotVerifiedCommand(meetingId: MeetingId(meetingId));
