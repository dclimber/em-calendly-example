import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/platform/event_store/event_store.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

/// The behavior that every [EventStore] adapter shares. [store] returns the adapter under test.
void eventStoreContract(EventStore Function() store) {
  const uuid = Uuid();

  // Fresh ids per test, so that tests also pass on a database that keeps the events of earlier runs.
  late String meetingId, hostId, otherHostId;
  setUp(() {
    meetingId = uuid.v4();
    hostId = uuid.v4();
    otherHostId = uuid.v4();
  });

  MeetingSlotReservedEvent reserved(String meeting, String host) => MeetingSlotReservedEvent(
    meetingId: MeetingId(meeting),
    hostId: HostId(host),
    bookerId: BookerId('bob-employee-id'),
    meetingTypeId: MeetingTypeId('meeting-type-of-$meeting'),
    meetingTitle: MeetingTitle('30-minute consultation'),
    meetingLocation: MeetingLocation('Room 4'),
    slotStart: SlotStart(DateTime.utc(2027, 3, 22, 9)),
    slotEnd: SlotEnd(DateTime.utc(2027, 3, 22, 9, 30)),
    participants: Participants([
      Participant(
        employeeId: EmployeeId(host),
        name: EmployeeName('Alice'),
        email: EmployeeEmail('alice@example.com'),
        role: 'host',
      ),
    ]),
  );

  MeetingConfirmedEvent confirmed(String meeting) =>
      MeetingConfirmedEvent(meetingId: MeetingId(meeting), calendarEventId: CalendarEventId('cal-1'));

  // @ensures read(queries) returns exactly the appended events that match a query, in append order
  test('reads the matching events in append order, decoded', () async {
    final s = store();
    final otherMeeting = uuid.v4();
    await s.append([reserved(meetingId, hostId)]);
    await s.append([reserved(otherMeeting, otherHostId)]);
    await s.append([confirmed(meetingId)]);

    final read = await s.read([
      (tag: 'meetingId', value: meetingId, eventTypes: [MeetingSlotReservedEvent, MeetingConfirmedEvent]),
    ]);

    expect(read.events.map((e) => e.event), [reserved(meetingId, hostId), confirmed(meetingId)]);
    expect(read.events.map((e) => e.typeName), ['MeetingSlotReservedEvent', 'MeetingConfirmedEvent']);
    expect(read.position, read.events.last.position);
    expect(read.events.first.position, lessThan(read.events.last.position));
    expect(read.events.first.stream, (type: 'meeting', id: meetingId));
  });

  // @ensures a query matches only the listed event types
  test('filters by event type', () async {
    final s = store();
    await s.append([reserved(meetingId, hostId), confirmed(meetingId)]);
    final read = await s.read([
      (tag: 'meetingId', value: meetingId, eventTypes: [MeetingConfirmedEvent]),
    ]);
    expect(read.events.map((e) => e.event), [confirmed(meetingId)]);
  });

  // @ensures every event of a stream also carries the tags of the stream's first event
  test('later events of a stream inherit the stream tags', () async {
    final s = store();
    await s.append([reserved(meetingId, hostId)]);
    await s.append([confirmed(meetingId)]);
    final read = await s.read([
      (tag: 'hostId', value: hostId, eventTypes: [MeetingConfirmedEvent]),
    ]);
    expect(read.events.map((e) => e.event), [confirmed(meetingId)]);
    expect(read.events.single.tagValue('hostId'), hostId);
    expect(read.events.single.tagValue('meetingId'), meetingId);
  });

  // @ensures stream tags apply inside one append batch too
  test('a batch that starts a stream gives its tags to the later events of the batch', () async {
    final s = store();
    final stored = await s.append([reserved(meetingId, hostId), confirmed(meetingId)]);
    expect(stored.last.tagValue('hostId'), hostId);
  });

  // @ensures read of no matching event has position 0
  test('an empty read has position 0', () async {
    final read = await store().read([
      (tag: 'meetingId', value: meetingId, eventTypes: [MeetingConfirmedEvent]),
    ]);
    expect(read.events, isEmpty);
    expect(read.position, 0);
  });

  // @requires another writer appended a matching event after the read
  // @ensures append with the condition of the read fails and appends nothing
  test('an append condition fails after a conflicting append', () async {
    final s = store();
    final queries = <EventQuery>[
      (tag: 'hostId', value: hostId, eventTypes: [MeetingSlotReservedEvent]),
    ];
    final read = await s.read(queries);
    await s.append([reserved(uuid.v4(), hostId)]);

    final late = reserved(meetingId, hostId);
    await expectLater(
      s.append([late], condition: read.conditionFor(queries)),
      throwsA(isA<AppendConditionFailed>()),
    );
    final after = await s.read([
      (tag: 'meetingId', value: meetingId, eventTypes: [MeetingSlotReservedEvent]),
    ]);
    expect(after.events, isEmpty);
  });

  // @ensures an append that touches other tags than the condition succeeds
  test('an append condition holds when only unrelated events were appended', () async {
    final s = store();
    final queries = <EventQuery>[
      (tag: 'hostId', value: hostId, eventTypes: [MeetingSlotReservedEvent]),
    ];
    final read = await s.read(queries);
    await s.append([reserved(uuid.v4(), otherHostId)]);
    final stored = await s.append([reserved(meetingId, hostId)], condition: read.conditionFor(queries));
    expect(stored.single.event, reserved(meetingId, hostId));
  });

  // @ensures events of several bounded contexts round-trip through the store
  test('stores events of different bounded contexts', () async {
    final s = store();
    final scheduleId = uuid.v4();
    final events = [
      EmployeeRegisteredEvent(
        employeeId: EmployeeId(hostId),
        employeeName: EmployeeName('Alice'),
        employeeEmail: EmployeeEmail('alice@example.com'),
      ),
      AvailabilityScheduleCreatedEvent(
        scheduleId: ScheduleId(scheduleId),
        hostId: HostId(hostId),
        scheduleName: ScheduleName('Working hours'),
        timeZone: TimeZone('Europe/Berlin'),
      ),
    ];
    for (final event in events) {
      await s.append([event]);
    }
    final read = await s.read([
      (tag: 'employeeId', value: hostId, eventTypes: [EmployeeRegisteredEvent]),
      (tag: 'scheduleId', value: scheduleId, eventTypes: [AvailabilityScheduleCreatedEvent]),
    ]);
    expect(read.events.map((e) => e.event), events);
  });
}
