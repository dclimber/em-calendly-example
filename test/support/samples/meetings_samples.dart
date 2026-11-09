/// One sample of every `meetings` event.
library;

import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';

/// One instance of every `meetings` event, with HCL example values where they exist.
List<MeetingsEvent> sampleMeetingsEvents() => [
  MeetingSlotReservedEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    hostId: HostId('alice-employee-id'),
    bookerId: BookerId('bob-employee-id'),
    meetingTypeId: MeetingTypeId('e3b5aceb-a393-5517-acf5-fb11936414a5'),
    meetingTitle: MeetingTitle('30-minute consultation'),
    meetingLocation: MeetingLocation('Video call'),
    slotStart: SlotStart(DateTime.utc(2026, 11, 16, 9, 0)),
    slotEnd: SlotEnd(DateTime.utc(2026, 11, 16, 9, 30)),
    participants: Participants([
      Participant(
        employeeId: EmployeeId('alice-employee-id'),
        name: EmployeeName('Alice Example'),
        email: EmployeeEmail('alice@example.com'),
        role: 'host',
      ),
      Participant(
        employeeId: EmployeeId('bob-employee-id'),
        name: EmployeeName('Bob Example'),
        email: EmployeeEmail('bob@example.com'),
        role: 'booker',
      ),
    ]),
  ),
  BookingAvailabilityCheckRequestedEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    hostId: HostId('alice-employee-id'),
    slotStart: SlotStart(DateTime.utc(2026, 11, 16, 9, 0)),
    slotEnd: SlotEnd(DateTime.utc(2026, 11, 16, 9, 30)),
  ),
  BookingSlotVerifiedEvent(meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766')),
  CalendarEventRequestedEvent(meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766')),
  MeetingConfirmedEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    calendarEventId: CalendarEventId('evt-7f3a9c'),
  ),
  MeetingBookingFailedEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    failureReason: FailureReason('The host is busy at that time'),
  ),
  BookingConfirmationSentEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    participants: Participants([
      Participant(
        employeeId: EmployeeId('alice-employee-id'),
        name: EmployeeName('Alice Example'),
        email: EmployeeEmail('alice@example.com'),
        role: 'host',
      ),
      Participant(
        employeeId: EmployeeId('bob-employee-id'),
        name: EmployeeName('Bob Example'),
        email: EmployeeEmail('bob@example.com'),
        role: 'booker',
      ),
    ]),
  ),
  MeetingRescheduleRequestedEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    hostId: HostId('alice-employee-id'),
    requestedBy: RequestedBy('bob-employee-id'),
    newSlotStart: NewSlotStart(DateTime.utc(2026, 11, 17, 14, 0)),
    newSlotEnd: NewSlotEnd(DateTime.utc(2026, 11, 17, 14, 30)),
    calendarEventId: CalendarEventId('evt-7f3a9c'),
    participants: Participants([
      Participant(
        employeeId: EmployeeId('alice-employee-id'),
        name: EmployeeName('Alice Example'),
        email: EmployeeEmail('alice@example.com'),
        role: 'host',
      ),
      Participant(
        employeeId: EmployeeId('bob-employee-id'),
        name: EmployeeName('Bob Example'),
        email: EmployeeEmail('bob@example.com'),
        role: 'booker',
      ),
    ]),
  ),
  RescheduleAvailabilityCheckRequestedEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    hostId: HostId('alice-employee-id'),
    newSlotStart: NewSlotStart(DateTime.utc(2026, 11, 17, 14, 0)),
    newSlotEnd: NewSlotEnd(DateTime.utc(2026, 11, 17, 14, 30)),
  ),
  NewSlotVerifiedEvent(meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766')),
  CalendarEventUpdateRequestedEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    newSlotStart: NewSlotStart(DateTime.utc(2026, 11, 17, 14, 0)),
  ),
  MeetingRescheduledEvent(meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766')),
  MeetingMovedInCalendarEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    newSlotStart: NewSlotStart(DateTime.utc(2026, 11, 17, 14, 0)),
    newSlotEnd: NewSlotEnd(DateTime.utc(2026, 11, 17, 14, 30)),
  ),
  MeetingRescheduleFailedEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    failureReason: FailureReason('The host is busy at that time'),
  ),
  RescheduleNoticeSentEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    newSlotStart: NewSlotStart(DateTime.utc(2026, 11, 17, 14, 0)),
    participants: Participants([
      Participant(
        employeeId: EmployeeId('alice-employee-id'),
        name: EmployeeName('Alice Example'),
        email: EmployeeEmail('alice@example.com'),
        role: 'host',
      ),
      Participant(
        employeeId: EmployeeId('bob-employee-id'),
        name: EmployeeName('Bob Example'),
        email: EmployeeEmail('bob@example.com'),
        role: 'booker',
      ),
    ]),
  ),
  MeetingCancellationRequestedEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    hostId: HostId('alice-employee-id'),
    requestedBy: RequestedBy('bob-employee-id'),
    calendarEventId: CalendarEventId('evt-7f3a9c'),
    participants: Participants([
      Participant(
        employeeId: EmployeeId('alice-employee-id'),
        name: EmployeeName('Alice Example'),
        email: EmployeeEmail('alice@example.com'),
        role: 'host',
      ),
      Participant(
        employeeId: EmployeeId('bob-employee-id'),
        name: EmployeeName('Bob Example'),
        email: EmployeeEmail('bob@example.com'),
        role: 'booker',
      ),
    ]),
  ),
  CalendarEventDeletionRequestedEvent(meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766')),
  MeetingCanceledEvent(meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766')),
  MeetingCancellationFailedEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    failureReason: FailureReason('The host is busy at that time'),
  ),
  CancellationNoticeSentEvent(
    meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    participants: Participants([
      Participant(
        employeeId: EmployeeId('alice-employee-id'),
        name: EmployeeName('Alice Example'),
        email: EmployeeEmail('alice@example.com'),
        role: 'host',
      ),
      Participant(
        employeeId: EmployeeId('bob-employee-id'),
        name: EmployeeName('Bob Example'),
        email: EmployeeEmail('bob@example.com'),
        role: 'booker',
      ),
    ]),
  ),
  MeetingCompletedEvent(meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766')),
];
