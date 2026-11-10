import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/platform/web/http.dart';
import 'package:em_calendly_example/slices/request_meeting_reschedule/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _meeting = MeetingId('mt-meeting-1');
final _slotStart = DateTime.utc(2027, 3, 22, 8);
final _slotEnd = DateTime.utc(2027, 3, 22, 8, 30);
final _newStart = DateTime.utc(2027, 3, 22, 9);
final _newEnd = DateTime.utc(2027, 3, 22, 9, 30);
const _stranger = Viewer(employeeId: 'dave-employee-id', name: 'Dave Stranger', email: 'dave@example.com');

/// Alice's schedule and calendar, and a meeting that Bob booked with her and that is confirmed.
List<DomainEvent> _setup() => [
  CalendarConnectedEvent(hostId: HostId('alice-employee-id'), calendarAccount: CalendarAccount('alice@example.com')),
  AvailabilityScheduleCreatedEvent(
    scheduleId: ScheduleId('sched-1'),
    hostId: HostId('alice-employee-id'),
    scheduleName: ScheduleName('Working hours'),
    timeZone: TimeZone('Europe/Berlin'),
  ),
  WeeklyHoursSetEvent(
    scheduleId: ScheduleId('sched-1'),
    weeklyHours: WeeklyHours([WeeklyHoursEntry(weekday: 'Monday', startTime: '09:00', endTime: '10:30')]),
  ),
  MeetingSlotReservedEvent(
    meetingId: _meeting,
    hostId: HostId('alice-employee-id'),
    bookerId: BookerId('bob-employee-id'),
    meetingTypeId: MeetingTypeId('mt-1'),
    meetingTitle: MeetingTitle('30-minute consultation'),
    meetingLocation: MeetingLocation('Video call'),
    slotStart: SlotStart(_slotStart),
    slotEnd: SlotEnd(_slotEnd),
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
  ),
  MeetingConfirmedEvent(meetingId: _meeting, calendarEventId: CalendarEventId('evt-1')),
];

Future<TestResponse> _requestNewTime(TestApp t, {Viewer? as = bob, DateTime? start, DateTime? end}) => t.post(
  confirmNewSlot('mt-meeting-1', start ?? _newStart, end ?? _newEnd),
  {'start': (start ?? _newStart).toIso8601String(), 'end': (end ?? _newEnd).toIso8601String()},
  as: as,
);

Future<List<MeetingRescheduleRequestedEvent>> _requests(TestApp t) async {
  final read = await t.events.read([
    (tag: 'meetingId', value: 'mt-meeting-1', eventTypes: const [MeetingRescheduleRequestedEvent]),
  ]);
  return [for (final stored in read.events) stored.event as MeetingRescheduleRequestedEvent];
}

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(now: DateTime.utc(2027, 3, 16, 8), slices: const [RequestMeetingRescheduleSlice()]);
    await t.start();
    await t.given(_setup());
    await t.drain();
  });

  test(
    'booker moves a confirmed meeting: the request is recorded and the meeting is redirected with a notice',
    () async {
      final response = await _requestNewTime(t);

      expect(response.statusCode, 303);
      expect(response.redirectPath, meetingDetails('mt-meeting-1'));
      expect(response.notice, 'Your new time is being confirmed.');
      final requests = await _requests(t);
      expect(requests, hasLength(1));
      expect(requests.single.newSlotStart.value, _newStart);
      expect(requests.single.newSlotEnd.value, _newEnd);
      expect(requests.single.requestedBy.value, bob.employeeId);
    },
  );

  test('a stranger is refused: nothing is recorded and the viewer is sent back to the slot picker', () async {
    final response = await _requestNewTime(t, as: _stranger);

    expect(response.redirectPath, rescheduleSlotPicker('mt-meeting-1'));
    expect(response.error, 'Only the participants of this meeting can change it.');
    expect(await _requests(t), isEmpty);
  });

  test('a second request while the first is pending is refused', () async {
    await _requestNewTime(t);
    await t.drain();

    final response = await _requestNewTime(
      t,
      start: DateTime.utc(2027, 3, 22, 9, 30),
      end: DateTime.utc(2027, 3, 22, 10),
    );

    expect(response.redirectPath, rescheduleSlotPicker('mt-meeting-1'));
    expect(response.error, 'Another change to this meeting is still in progress.');
    expect(await _requests(t), hasLength(1));
  });
}
