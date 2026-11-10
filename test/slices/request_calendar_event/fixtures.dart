import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';

/// The `meeting_slot_reserved` event of the examples: Bob books Alice's intro call, with both participants.
MeetingSlotReservedEvent reservedEvent({String meetingId = 'meeting-1', DateTime? slotStart, DateTime? slotEnd}) =>
    MeetingSlotReservedEvent(
      meetingId: MeetingId(meetingId),
      hostId: HostId('alice-employee-id'),
      bookerId: BookerId('bob-employee-id'),
      meetingTypeId: MeetingTypeId('intro-call-type'),
      meetingTitle: MeetingTitle('Intro call'),
      meetingLocation: MeetingLocation('Room 1'),
      slotStart: SlotStart(slotStart ?? DateTime.utc(2027, 3, 15, 9)),
      slotEnd: SlotEnd(slotEnd ?? DateTime.utc(2027, 3, 15, 9, 30)),
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

/// The `booking_slot_verified` event that the calendar check of [meetingId] records.
BookingSlotVerifiedEvent verifiedEvent({String meetingId = 'meeting-1'}) =>
    BookingSlotVerifiedEvent(meetingId: MeetingId(meetingId));

/// The `calendar_event_requested` event that the decider emits for [meetingId].
CalendarEventRequestedEvent requestedEvent({String meetingId = 'meeting-1'}) =>
    CalendarEventRequestedEvent(meetingId: MeetingId(meetingId));
