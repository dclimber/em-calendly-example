import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_meeting_reschedule/command.dart';
import 'package:em_calendly_example/slices/request_meeting_reschedule/decider.dart';
import 'package:em_calendly_example/slices/request_meeting_reschedule/errors.dart';
import 'package:em_calendly_example/slices/request_meeting_reschedule/state.dart';
import 'package:test/test.dart';

final _host = HostId('alice-employee-id');
final _booker = BookerId('carol-employee-id');
final _stranger = RequestedBy('dave-employee-id');
final _schedule = ScheduleId('schedule-1');
final _meeting = MeetingId('meeting-1');
final _other = MeetingId('meeting-2');
final _now = DateTime.utc(2027, 3, 16, 8);
final _slotStart = DateTime.utc(2027, 3, 22, 9);
final _slotEnd = DateTime.utc(2027, 3, 22, 9, 30);
final _newStart = DateTime.utc(2027, 3, 22, 10);
final _newEnd = DateTime.utc(2027, 3, 22, 10, 30);

/// The host's schedule and calendar: a UTC schedule open Monday 09:00 to 10:30, and a verified calendar.
final List<DomainEvent> _base = [
  AvailabilityScheduleCreatedEvent(
    scheduleId: _schedule,
    hostId: _host,
    scheduleName: ScheduleName('Working hours'),
    timeZone: TimeZone('UTC'),
  ),
  WeeklyHoursSetEvent(
    scheduleId: _schedule,
    weeklyHours: WeeklyHours([WeeklyHoursEntry(weekday: 'Monday', startTime: '09:00', endTime: '10:30')]),
  ),
  CalendarConnectedEvent(hostId: _host, calendarAccount: CalendarAccount('alice@example.com')),
];

/// A reserved meeting of the host with [_booker], in the slot [start] to [end].
MeetingSlotReservedEvent _reserved({MeetingId? meetingId, DateTime? start, DateTime? end}) => MeetingSlotReservedEvent(
  meetingId: meetingId ?? _meeting,
  hostId: _host,
  bookerId: _booker,
  meetingTypeId: MeetingTypeId('meeting-type-1'),
  meetingTitle: MeetingTitle('30-minute consultation'),
  meetingLocation: MeetingLocation('Video call'),
  slotStart: SlotStart(start ?? _slotStart),
  slotEnd: SlotEnd(end ?? _slotEnd),
  participants: Participants([
    Participant(
      employeeId: EmployeeId(_host.value),
      name: EmployeeName('Alice'),
      email: EmployeeEmail('alice@example.com'),
      role: 'host',
    ),
    Participant(
      employeeId: EmployeeId(_booker.value),
      name: EmployeeName('Carol'),
      email: EmployeeEmail('carol@example.com'),
      role: 'booker',
    ),
  ]),
);

final _confirmed = <DomainEvent>[
  _reserved(),
  MeetingConfirmedEvent(meetingId: _meeting, calendarEventId: CalendarEventId('evt-1')),
];

RequestMeetingRescheduleCommand _request({
  MeetingId? meetingId,
  String? requestedBy,
  DateTime? start,
  DateTime? end,
}) => RequestMeetingRescheduleCommand(
  meetingId: meetingId ?? _meeting,
  hostId: _host,
  requestedBy: RequestedBy(requestedBy ?? _booker.value),
  newSlotStart: start ?? _newStart,
  newSlotEnd: end ?? _newEnd,
  now: _now,
);

RescheduleState _fold(List<DomainEvent> history) =>
    history.fold(requestMeetingRescheduleDecider.initialState, requestMeetingRescheduleDecider.evolve);

Future<List<DomainEvent>> _decide(RequestMeetingRescheduleCommand command, List<DomainEvent> history) =>
    requestMeetingRescheduleDecider.decide(command, _fold([..._base, ...history])).toList();

void main() {
  group('happy_path', () {
    test('participant_requests_a_new_time: the booker moves a confirmed meeting', () async {
      final emitted = await _decide(_request(), _confirmed);

      expect(emitted, [
        isA<MeetingRescheduleRequestedEvent>()
            .having((e) => e.meetingId, 'meetingId', _meeting)
            .having((e) => e.newSlotStart.value, 'newSlotStart', _newStart)
            .having((e) => e.newSlotEnd.value, 'newSlotEnd', _newEnd)
            .having((e) => e.calendarEventId.value, 'calendarEventId', 'evt-1'),
      ]);
    });

    test('the host may request a new time as well', () async {
      final emitted = await _decide(_request(requestedBy: _host.value), _confirmed);

      expect(emitted.single, isA<MeetingRescheduleRequestedEvent>());
    });

    test('the meeting may keep its own slot: its current time is not a conflict', () async {
      final emitted = await _decide(_request(start: _slotStart, end: _slotEnd), _confirmed);

      expect(emitted.single, isA<MeetingRescheduleRequestedEvent>());
    });
  });

  group('state_violation', () {
    for (final ended in [
      ('canceled_meeting_cannot_be_rescheduled', MeetingCanceledEvent(meetingId: _meeting)),
      ('completed_meeting_cannot_be_rescheduled', MeetingCompletedEvent(meetingId: _meeting)),
      (
        'booking_failed_meeting_cannot_be_rescheduled',
        MeetingBookingFailedEvent(meetingId: _meeting, failureReason: FailureReason('calendar down')),
      ),
    ]) {
      test(ended.$1, () async {
        await expectLater(_decide(_request(), [..._confirmed, ended.$2]), throwsA(isA<MeetingEndedError>()));
      });
    }

    test('second_change_waits_for_the_first: a request while rescheduling is refused', () async {
      final history = [
        ..._confirmed,
        MeetingRescheduleRequestedEvent(
          meetingId: _meeting,
          hostId: _host,
          requestedBy: RequestedBy(_booker.value),
          newSlotStart: NewSlotStart(_newStart),
          newSlotEnd: NewSlotEnd(_newEnd),
          calendarEventId: CalendarEventId('evt-1'),
          participants: Participants([]),
        ),
      ];

      await expectLater(_decide(_request(), history), throwsA(isA<ChangeInProgressError>()));
    });

    test('a meeting still pending in the calendar cannot be rescheduled yet', () async {
      await expectLater(_decide(_request(), [_reserved()]), throwsA(isA<ChangeInProgressError>()));
    });
  });

  group('authorization', () {
    test('non_participant_is_refused', () async {
      await expectLater(
        _decide(_request(requestedBy: _stranger.value), _confirmed),
        throwsA(isA<NotAParticipantError>()),
      );
    });

    test('a meeting that was never reserved has no participants to refuse', () async {
      await expectLater(_decide(_request(), const []), throwsA(isA<NotAParticipantError>()));
    });
  });

  group('variant', () {
    test('new_slot_already_taken_is_refused: another meeting of the host holds the slot', () async {
      final history = [
        ..._confirmed,
        _reserved(meetingId: _other, start: _newStart, end: _newEnd),
      ];

      await expectLater(_decide(_request(), history), throwsA(isA<SlotUnavailableError>()));
    });

    test('a new slot that the host is busy in is refused', () async {
      final history = [
        ..._confirmed,
        HostBusyTimesRecordedEvent(
          hostId: _host,
          busyIntervals: BusyIntervals([BusyInterval(busyFrom: _newStart, busyUntil: _newEnd)]),
        ),
      ];

      await expectLater(_decide(_request(), history), throwsA(isA<SlotUnavailableError>()));
    });

    test('a new slot outside the host rules is refused', () async {
      await expectLater(
        _decide(_request(start: DateTime.utc(2027, 3, 23, 9), end: DateTime.utc(2027, 3, 23, 9, 30)), _confirmed),
        throwsA(isA<SlotOutsideRulesError>()),
      );
    });

    test('an unverified calendar refuses the new slot', () async {
      final history = [
        ..._confirmed,
        CalendarConnectionFailedEvent(hostId: _host, connectionFailure: ConnectionFailure('token expired')),
      ];

      await expectLater(_decide(_request(), history), throwsA(isA<CalendarUnverifiedError>()));
    });
  });
}
