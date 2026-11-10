import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/platform/web/http.dart';
import 'package:em_calendly_example/slices/reserve_meeting_slot/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _meetingType = MeetingTypeId('mt-1');
final _slotStart = DateTime.utc(2027, 3, 22, 8);
final _slotEnd = DateTime.utc(2027, 3, 22, 8, 30);

List<DomainEvent> _setup() => [
  EmployeeRegisteredEvent(
    employeeId: EmployeeId('alice-employee-id'),
    employeeName: EmployeeName('Alice Example'),
    employeeEmail: EmployeeEmail('alice@example.com'),
  ),
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
  MeetingTypeCreatedEvent(
    meetingTypeId: _meetingType,
    hostId: HostId('alice-employee-id'),
    meetingTitle: MeetingTitle('30-minute consultation'),
    durationMinutes: DurationMinutes(30),
    meetingLocation: MeetingLocation('Video call'),
    scheduleId: ScheduleId('sched-1'),
    bookingUrl: BookingUrl('https://scheduler.example.com/book/mt-1'),
  ),
];

/// The reservations of alice, as they are in the store.
Future<List<MeetingSlotReservedEvent>> _reservations(TestApp t) async {
  final read = await t.events.read([
    (tag: 'hostId', value: 'alice-employee-id', eventTypes: const [MeetingSlotReservedEvent]),
  ]);
  return [for (final stored in read.events) stored.event as MeetingSlotReservedEvent];
}

Future<TestResponse> _book(TestApp t, {required DateTime start, required DateTime end, Viewer? as = bob}) =>
    t.post(reviewBooking('mt-1', start, end), {'start': start.toIso8601String(), 'end': end.toIso8601String()}, as: as);

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(now: DateTime.utc(2027, 3, 16, 8), slices: const [ReserveMeetingSlotSlice()]);
    await t.start();
    await t.given(_setup());
    await t.drain();
  });

  test(
    'booker reserves a free slot: meeting_slot_reserved with host and booker, and a redirect to the result',
    () async {
      final response = await _book(t, start: _slotStart, end: _slotEnd);

      expect(response.statusCode, 303);
      final reservations = await _reservations(t);
      expect(reservations, hasLength(1));
      final reserved = reservations.single;
      expect(reserved.hostId.value, 'alice-employee-id');
      expect(reserved.bookerId.value, bob.employeeId);
      expect(reserved.meetingTypeId, _meetingType);
      expect(reserved.slotStart.value, _slotStart);
      expect(reserved.slotEnd.value, _slotEnd);
      expect(reserved.participants.items.map((p) => (p.name.value, p.role)), [
        ('Alice Example', 'host'),
        ('Bob Booker', 'booker'),
      ]);
      expect(response.location, startsWith('/bookings/'));
      expect(response.location, contains(Uri.encodeQueryComponent('Your booking is being confirmed.')));
    },
  );

  test('a second booking of the same slot is refused with the model text, and nothing is appended', () async {
    await _book(t, start: _slotStart, end: _slotEnd);
    final response = await _book(t, start: _slotStart, end: _slotEnd, as: _carol);

    expect(response.statusCode, 303);
    expect(
      Uri.parse(response.location!).queryParameters['error'],
      'This time was just booked. Please choose another slot.',
    );
    expect(await _reservations(t), hasLength(1));
  });

  test('a slot whose booking failed is released and can be booked again', () async {
    await _book(t, start: _slotStart, end: _slotEnd);
    final meetingId = (await _reservations(t)).single.meetingId;
    await t.given([
      MeetingBookingFailedEvent(meetingId: meetingId, failureReason: FailureReason('The calendar rejected the event')),
    ]);
    await t.drain();

    final response = await _book(t, start: _slotStart, end: _slotEnd, as: _carol);

    expect(response.statusCode, 303);
    expect(response.location, startsWith('/bookings/'));
    expect(await _reservations(t), hasLength(2));
  });

  test('a host cannot book their own link', () async {
    final response = await _book(t, start: _slotStart, end: _slotEnd, as: alice);

    expect(Uri.parse(response.location!).queryParameters['error'], 'You cannot book a meeting with yourself.');
    expect(await _reservations(t), isEmpty);
  });

  test('a disabled meeting type is refused', () async {
    await t.given([MeetingTypeDisabledEvent(meetingTypeId: _meetingType)]);
    await t.drain();
    final response = await _book(t, start: _slotStart, end: _slotEnd);

    expect(Uri.parse(response.location!).queryParameters['error'], 'This meeting type is not accepting bookings.');
    expect(await _reservations(t), isEmpty);
  });

  test('an unverified calendar is refused', () async {
    await t.given([
      CalendarConnectionFailedEvent(
        hostId: HostId('alice-employee-id'),
        connectionFailure: ConnectionFailure('expired'),
      ),
    ]);
    await t.drain();
    final response = await _book(t, start: _slotStart, end: _slotEnd);

    expect(
      Uri.parse(response.location!).queryParameters['error'],
      "The host's availability cannot be verified right now. Please try again later.",
    );
    expect(await _reservations(t), isEmpty);
  });

  test('a slot outside the weekly hours is refused', () async {
    final response = await _book(t, start: DateTime.utc(2027, 3, 22, 12), end: DateTime.utc(2027, 3, 22, 12, 30));

    expect(
      Uri.parse(response.location!).queryParameters['error'],
      "This time is outside the host's booking rules. Please choose another slot.",
    );
    expect(await _reservations(t), isEmpty);
  });

  test('an unauthenticated post is refused and nothing is appended', () async {
    final response = await _book(t, start: _slotStart, end: _slotEnd, as: null);

    expect(response.location, isNot(startsWith('/bookings/')));
    expect(await _reservations(t), isEmpty);
  });
}

const _carol = Viewer(employeeId: 'carol-employee-id', name: 'Carol Stranger', email: 'carol@example.com');
