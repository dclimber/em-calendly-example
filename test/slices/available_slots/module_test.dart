import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/platform/web/http.dart';
import 'package:em_calendly_example/slices/available_slots/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _meetingType = MeetingTypeId('mt-1');
final _meetingId = MeetingId('meeting-1');
const _carol = Viewer(employeeId: 'carol-employee-id', name: 'Carol Stranger', email: 'carol@example.com');

/// The href as it appears in HTML, where `&` is escaped.
String _html(String href) => href.replaceAll('&', '&amp;');

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

MeetingSlotReservedEvent _reserved() => MeetingSlotReservedEvent(
  meetingId: _meetingId,
  hostId: HostId('alice-employee-id'),
  bookerId: BookerId(bob.employeeId),
  meetingTypeId: _meetingType,
  meetingTitle: MeetingTitle('30-minute consultation'),
  meetingLocation: MeetingLocation('Video call'),
  slotStart: SlotStart(DateTime.utc(2027, 3, 22, 8)),
  slotEnd: SlotEnd(DateTime.utc(2027, 3, 22, 8, 30)),
  participants: Participants([
    Participant(
      employeeId: EmployeeId('alice-employee-id'),
      name: EmployeeName('Alice Example'),
      email: EmployeeEmail('alice@example.com'),
      role: 'host',
    ),
    Participant(
      employeeId: EmployeeId(bob.employeeId),
      name: EmployeeName('Bob Example'),
      email: EmployeeEmail('bob@example.com'),
      role: 'booker',
    ),
  ]),
);

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(now: DateTime.utc(2027, 3, 16, 8), slices: const [AvailableSlotsSlice()]);
    await t.start();
  });

  test('booking page: lists the host and a review link for a free slot', () async {
    await t.given(_setup());
    await t.drain();
    final response = await t.get(bookingPage('mt-1'), as: bob);

    expect(response.statusCode, 200);
    expect(response.body, contains('Alice Example'));
    final href = reviewBooking('mt-1', DateTime.utc(2027, 3, 22, 8), DateTime.utc(2027, 3, 22, 8, 30));
    expect(response.body, contains(_html(href)));
  });

  test('disabled meeting type: the page says it is not accepting and offers no review links', () async {
    await t.given([..._setup(), MeetingTypeDisabledEvent(meetingTypeId: _meetingType)]);
    await t.drain();
    final response = await t.get(bookingPage('mt-1'), as: bob);

    expect(response.body, contains('This meeting type is not accepting bookings.'));
    expect(response.body, isNot(contains('/app/book/mt-1/review')));
  });

  test('reschedule picker: a participant sees confirm links; a stranger sees the denial', () async {
    await t.given([..._setup(), _reserved()]);
    await t.drain();

    final participant = await t.get(rescheduleSlotPicker('meeting-1'), as: bob);
    expect(participant.statusCode, 200);
    expect(participant.body, contains('/app/meetings/meeting-1/reschedule/confirm'));

    final stranger = await t.get(rescheduleSlotPicker('meeting-1'), as: _carol);
    expect(stranger.body, contains('Only the participants of this meeting can move it.'));
    expect(stranger.body, isNot(contains('/app/meetings/meeting-1/reschedule/confirm')));
  });
}
