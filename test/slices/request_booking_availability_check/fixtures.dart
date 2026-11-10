import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_booking_availability_check/request_booking_availability_check/command.dart';

/// The `meeting_slot_reserved` event of the examples: Bob books Alice's intro call.
MeetingSlotReservedEvent reservedEvent({
  String meetingId = 'meeting-1',
  DateTime? slotStart,
  DateTime? slotEnd,
}) => MeetingSlotReservedEvent(
  meetingId: MeetingId(meetingId),
  hostId: HostId('alice-employee-id'),
  bookerId: BookerId('bob-employee-id'),
  meetingTypeId: MeetingTypeId('intro-call-type'),
  meetingTitle: MeetingTitle('Intro call'),
  meetingLocation: MeetingLocation('Room 1'),
  slotStart: SlotStart(slotStart ?? DateTime.utc(2027, 3, 15, 9)),
  slotEnd: SlotEnd(slotEnd ?? DateTime.utc(2027, 3, 15, 9, 30)),
  participants: Participants.empty(),
);

/// The command that the processor sends for the item that [reserved] opens.
RequestBookingAvailabilityCheckCommand commandFor(MeetingSlotReservedEvent reserved) =>
    RequestBookingAvailabilityCheckCommand(
      meetingId: reserved.meetingId,
      hostId: reserved.hostId,
      slotStart: reserved.slotStart,
      slotEnd: reserved.slotEnd,
    );
