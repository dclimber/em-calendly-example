import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/available_slots/state.dart';
import 'package:em_calendly_example/slices/available_slots/view.dart';
import 'package:test/test.dart';

final _alice = HostId('alice-employee-id');
final _bob = BookerId('bob-employee-id');
final _meetingType = MeetingTypeId('mt-1');
final _meetingId = MeetingId('meeting-1');

AvailableSlotsState? _fold(List<DomainEvent> events) {
  AvailableSlotsState? state;
  for (final event in events) {
    state = availableSlotsView.evolve(state, event);
  }
  return state;
}

/// Alice works Monday 09:00–10:30 in Berlin, offers 30-minute slots, and is free apart from the busy times given.
List<DomainEvent> _baseline({List<BusyInterval> busy = const []}) => [
  EmployeeRegisteredEvent(
    employeeId: EmployeeId('alice-employee-id'),
    employeeName: EmployeeName('Alice Example'),
    employeeEmail: EmployeeEmail('alice@example.com'),
  ),
  AvailabilityScheduleCreatedEvent(
    scheduleId: ScheduleId('sched-1'),
    hostId: _alice,
    scheduleName: ScheduleName('Working hours'),
    timeZone: TimeZone('Europe/Berlin'),
  ),
  WeeklyHoursSetEvent(
    scheduleId: ScheduleId('sched-1'),
    weeklyHours: WeeklyHours([
      WeeklyHoursEntry(weekday: 'Monday', startTime: '09:00', endTime: '10:30'),
    ]),
  ),
  MeetingTypeCreatedEvent(
    meetingTypeId: _meetingType,
    hostId: _alice,
    meetingTitle: MeetingTitle('30-minute consultation'),
    durationMinutes: DurationMinutes(30),
    meetingLocation: MeetingLocation('Video call'),
    scheduleId: ScheduleId('sched-1'),
    bookingUrl: BookingUrl('https://scheduler.example.com/book/mt-1'),
  ),
  HostBusyTimesRecordedEvent(hostId: _alice, busyIntervals: BusyIntervals(busy)),
];

List<(DateTime, DateTime)> _slotsOf(AvailableSlotsState state, DateTime now, {String? exceptMeetingId}) => [
  for (final slot in state.slotsOf(_meetingType.value, now, exceptMeetingId: exceptMeetingId).items)
    (slot.startAt.toUtc(), slot.endAt.toUtc()),
];

void main() {
  final now = DateTime.utc(2027, 3, 15, 8);

  test('local hours hold across daylight saving', () {
    final state = _fold(_baseline())!;
    final slots = _slotsOf(state, now);
    expect(slots.where((s) => s.$1 == DateTime.utc(2027, 3, 22, 8)), hasLength(1));
    expect(slots.where((s) => s.$1 == DateTime.utc(2027, 3, 29, 7)), hasLength(1));
  });

  test('only slots that satisfy the rules appear', () {
    final state = _fold(
      _baseline(
        busy: [BusyInterval(busyFrom: DateTime.utc(2027, 3, 22, 8, 30), busyUntil: DateTime.utc(2027, 3, 22, 9))],
      ),
    )!;
    final monday = _slotsOf(state, now).where((s) => s.$1.day == 22).toList();
    expect(monday, [
      (DateTime.utc(2027, 3, 22, 8), DateTime.utc(2027, 3, 22, 8, 30)),
      (DateTime.utc(2027, 3, 22, 9), DateTime.utc(2027, 3, 22, 9, 30)),
    ]);
  });

  test('a held meeting hides its slot; rescheduling excludes its own held range', () {
    final state = _fold([
      ..._baseline(),
      MeetingSlotReservedEvent(
        meetingId: _meetingId,
        hostId: _alice,
        bookerId: _bob,
        meetingTypeId: _meetingType,
        meetingTitle: MeetingTitle('30-minute consultation'),
        meetingLocation: MeetingLocation('Video call'),
        slotStart: SlotStart(DateTime.utc(2027, 3, 22, 8)),
        slotEnd: SlotEnd(DateTime.utc(2027, 3, 22, 8, 30)),
        participants: Participants([]),
      ),
    ])!;
    expect(_slotsOf(state, now).any((s) => s.$1 == DateTime.utc(2027, 3, 22, 8)), isFalse);
    expect(
      _slotsOf(state, now, exceptMeetingId: _meetingId.value).any((s) => s.$1 == DateTime.utc(2027, 3, 22, 8)),
      isTrue,
    );
  });

  test('a disabled meeting type stays reschedulable but is not accepting', () {
    final state = _fold([
      ..._baseline(),
      MeetingTypeDisabledEvent(meetingTypeId: _meetingType),
    ])!;
    expect(state.meetingTypes[_meetingType.value]!.accepting, isFalse);
  });

  test('events about a meeting type before its host exists change nothing', () {
    expect(_fold([MeetingTypeDisabledEvent(meetingTypeId: _meetingType)]), isNull);
  });
}
