import 'package:em_calendly_example/bounded_contexts/corporate_sso/api.dart';
import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/platform/corporate_calendar/mock_corporate_calendar.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp t;
  setUp(() async {
    t = TestApp(slices: const []);
    await t.start();
    await t.given([
      EmployeeRegisteredEvent(
        employeeId: EmployeeId(alice.employeeId),
        employeeName: EmployeeName(alice.name),
        employeeEmail: EmployeeEmail(alice.email),
      ),
    ]);
  });

  List<Object> appended<T>() => [
    for (final e in t.events.all)
      if (e.event is T) e.event,
  ];

  final slotStart = DateTime.utc(2027, 3, 22, 9);
  final slotEnd = DateTime.utc(2027, 3, 22, 9, 30);
  const meetingId = 'meeting-1';

  MeetingSlotReservedEvent reserved() => MeetingSlotReservedEvent(
    meetingId: MeetingId(meetingId),
    hostId: HostId(alice.employeeId),
    bookerId: BookerId(bob.employeeId),
    meetingTypeId: MeetingTypeId('type-1'),
    meetingTitle: MeetingTitle('30-minute consultation'),
    meetingLocation: MeetingLocation('Room 4'),
    slotStart: SlotStart(slotStart),
    slotEnd: SlotEnd(slotEnd),
    participants: Participants([
      Participant(
        employeeId: EmployeeId(alice.employeeId),
        name: EmployeeName(alice.name),
        email: EmployeeEmail(alice.email),
        role: 'host',
      ),
      Participant(
        employeeId: EmployeeId(bob.employeeId),
        name: EmployeeName(bob.name),
        email: EmployeeEmail(bob.email),
        role: 'booker',
      ),
    ]),
  );

  // @ensures a started connection is answered with calendar_access_granted and a first free/busy report
  test('grants access and reports free/busy data when a connection starts', () async {
    t.calendar.addBusyBlock(alice.email, (from: slotStart, until: slotEnd));
    await t.given([CalendarConnectionStartedEvent(hostId: HostId(alice.employeeId))]);
    await t.drain();
    expect(appended<CalendarAccessGrantedEvent>(), [
      CalendarAccessGrantedEvent(schedulerUserRef: SchedulerUserRef(alice.employeeId), calendarAccount: alice.email),
    ]);
    final report = appended<FreeBusyReportedEvent>().single as FreeBusyReportedEvent;
    expect(report.freeBusyBlocks, FreeBusyBlocks([FreeBusyBlock(busyFrom: slotStart, busyUntil: slotEnd)]));

    // @ensures an unchanged free/busy answer is not reported again
    await t.runJobs();
    expect(appended<FreeBusyReportedEvent>(), hasLength(1));
  });

  // @requires the host connects right after the first sign-in, before employee_registered is recorded
  // @ensures the connection uses the work email of the corporate sign-in
  test('connects a host whose registration is still on its way', () async {
    await t.given([
      const CorporateSignInSucceededEvent(ssoSubject: 'carol-id', displayName: 'Carol', workEmail: 'carol@example.com'),
      CalendarConnectionStartedEvent(hostId: HostId('carol-id')),
    ]);
    await t.drain();
    expect(appended<CalendarAccessGrantedEvent>(), [
      CalendarAccessGrantedEvent(schedulerUserRef: SchedulerUserRef('carol-id'), calendarAccount: 'carol@example.com'),
    ]);
  });

  // @ensures a refused connection is answered with calendar_access_failed and its code
  test('reports a failed connection', () async {
    t.calendar.failOperation(MockCalendarOperation.connect, 'consent_denied');
    await t.given([CalendarConnectionStartedEvent(hostId: HostId(alice.employeeId))]);
    await t.drain();
    expect(appended<CalendarAccessFailedEvent>(), [
      CalendarAccessFailedEvent(
        failureCode: FailureCode('consent_denied'),
        schedulerUserRef: SchedulerUserRef(alice.employeeId),
      ),
    ]);
  });

  // @ensures the live check answers free or busy for the held slot
  test('answers a booking availability check', () async {
    final request = BookingAvailabilityCheckRequestedEvent(
      meetingId: MeetingId(meetingId),
      hostId: HostId(alice.employeeId),
      slotStart: SlotStart(slotStart),
      slotEnd: SlotEnd(slotEnd),
    );
    await t.given([request]);
    await t.drain();
    t.calendar.addBusyBlock(alice.email, (from: slotStart, until: slotEnd));
    await t.given([request]);
    await t.drain();
    expect([for (final e in t.events.all) e.event.runtimeType].where((t) => t.toString().startsWith('HostSlot')), [
      HostSlotFoundFreeEvent,
      HostSlotFoundBusyEvent,
    ]);
  });

  // @ensures a requested event is created with the participants, and later direct moves and deletions are reported
  test('creates the meeting event and reports direct changes', () async {
    await t.given([reserved(), CalendarEventRequestedEvent(meetingId: MeetingId(meetingId))]);
    await t.drain();
    final created = appended<CalendarEventCreatedEvent>().single as CalendarEventCreatedEvent;
    final event = t.calendar.events.single;
    expect(created.providerEventRef, event.id);
    expect(event.details.attendeeEmails, [alice.email, bob.email]);

    final movedStart = slotStart.add(const Duration(hours: 2));
    final movedEnd = slotEnd.add(const Duration(hours: 2));
    t.calendar.moveDirectly(event.id, movedStart, movedEnd);
    await t.runJobs();
    expect(appended<CalendarEventMovedDirectlyEvent>(), [
      CalendarEventMovedDirectlyEvent(
        schedulerMeetingRef: SchedulerMeetingRef(meetingId),
        movedStart: movedStart,
        movedEnd: movedEnd,
      ),
    ]);
    await t.runJobs();
    expect(appended<CalendarEventMovedDirectlyEvent>(), hasLength(1), reason: 'a move is reported once');

    t.calendar.deleteDirectly(event.id);
    await t.runJobs();
    expect(appended<CalendarEventDeletedDirectlyEvent>(), hasLength(1));
  });

  // @ensures a failed creation is answered with calendar_event_creation_failed
  test('reports a failed event creation', () async {
    t.calendar.failOperation(MockCalendarOperation.create, 'quota_exceeded');
    await t.given([reserved(), CalendarEventRequestedEvent(meetingId: MeetingId(meetingId))]);
    await t.drain();
    expect(appended<CalendarEventCreationFailedEvent>(), [
      CalendarEventCreationFailedEvent(
        failureCode: FailureCode('quota_exceeded'),
        schedulerMeetingRef: SchedulerMeetingRef(meetingId),
      ),
    ]);
  });
}
