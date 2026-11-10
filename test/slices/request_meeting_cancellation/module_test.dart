import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/platform/web/http.dart';
import 'package:em_calendly_example/slices/request_meeting_cancellation/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _meeting = MeetingId('mt-meeting-1');
final _slotStart = DateTime.utc(2027, 3, 22, 8);
final _slotEnd = DateTime.utc(2027, 3, 22, 8, 30);
const _stranger = Viewer(employeeId: 'dave-employee-id', name: 'Dave Stranger', email: 'dave@example.com');

/// Alice's schedule and calendar, and a meeting that Bob booked with her and that is confirmed.
List<DomainEvent> _setup() => [
  MeetingTypeCreatedEvent(
    meetingTypeId: MeetingTypeId('mt-1'),
    hostId: HostId('alice-employee-id'),
    meetingTitle: MeetingTitle('30-minute consultation'),
    durationMinutes: DurationMinutes(30),
    meetingLocation: MeetingLocation('Video call'),
    scheduleId: ScheduleId('sched-1'),
    bookingUrl: BookingUrl('http://x/book/mt-1'),
  ),
  CalendarConnectedEvent(hostId: HostId('alice-employee-id'), calendarAccount: CalendarAccount('alice@example.com')),
  AvailabilityScheduleCreatedEvent(
    scheduleId: ScheduleId('sched-1'),
    hostId: HostId('alice-employee-id'),
    scheduleName: ScheduleName('Working hours'),
    timeZone: TimeZone('Europe/Berlin'),
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

Future<TestResponse> _cancelMeeting(TestApp t, {Viewer? as = bob}) =>
    t.post(confirmCancellation('mt-meeting-1'), {}, as: as);

Future<List<MeetingCancellationRequestedEvent>> _requests(TestApp t) async {
  final read = await t.events.read([
    (tag: 'meetingId', value: 'mt-meeting-1', eventTypes: const [MeetingCancellationRequestedEvent]),
  ]);
  return [for (final stored in read.events) stored.event as MeetingCancellationRequestedEvent];
}

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(now: DateTime.utc(2027, 3, 16, 8), slices: const [RequestMeetingCancellationSlice()]);
    await t.start();
    await t.given(_setup());
    await t.drain();
  });

  test(
    'the booker cancels a confirmed meeting: the request is recorded and the meeting redirects with a notice',
    () async {
      final response = await _cancelMeeting(t);

      expect(response.notice, isNotNull);
      expect(response.redirectPath, meetingDetails('mt-meeting-1'));
      final requests = await _requests(t);
      expect(requests, hasLength(1));
      expect(requests.single.requestedBy.value, 'bob-employee-id');
      expect(requests.single.calendarEventId.value, 'evt-1');
    },
  );

  test('a stranger is refused and nothing is recorded', () async {
    final response = await _cancelMeeting(t, as: _stranger);

    expect(response.error, 'Only the participants of this meeting can change it.');
    expect(response.redirectPath, meetingDetails('mt-meeting-1'));
    expect(await _requests(t), isEmpty);
  });

  test('a meeting in rescheduling is refused', () async {
    await t.given([
      MeetingRescheduleRequestedEvent(
        meetingId: _meeting,
        hostId: HostId('alice-employee-id'),
        requestedBy: RequestedBy('bob-employee-id'),
        newSlotStart: NewSlotStart(DateTime.utc(2027, 3, 22, 9)),
        newSlotEnd: NewSlotEnd(DateTime.utc(2027, 3, 22, 9, 30)),
        calendarEventId: CalendarEventId('evt-1'),
        participants: Participants.empty(),
      ),
    ]);
    await t.drain();

    final response = await _cancelMeeting(t);

    expect(response.error, 'Another change to this meeting is still in progress.');
    expect(await _requests(t), isEmpty);
  });
}
