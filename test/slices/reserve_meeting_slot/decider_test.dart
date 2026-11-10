import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/reserve_meeting_slot/command.dart';
import 'package:em_calendly_example/slices/reserve_meeting_slot/decider.dart';
import 'package:em_calendly_example/slices/reserve_meeting_slot/errors.dart';
import 'package:em_calendly_example/slices/reserve_meeting_slot/state.dart';
import 'package:test/test.dart';

final _host = HostId('alice-employee-id');
final _booker = BookerId('bob-employee-id');
final _type = MeetingTypeId('meeting-type-1');
final _schedule = ScheduleId('schedule-1');
final _newMeeting = MeetingId('meeting-new');
final _heldMeeting = MeetingId('meeting-held');
final _now = DateTime.utc(2027, 3, 16, 8);
final _slotStart = DateTime.utc(2027, 3, 22, 9);
final _slotEnd = DateTime.utc(2027, 3, 22, 9, 30);
final _laterStart = DateTime.utc(2027, 3, 22, 10);
final _laterEnd = DateTime.utc(2027, 3, 22, 10, 30);

/// The host's schedule and calendar, as the model's givens presuppose them: a UTC schedule open Monday 09:00 to
/// 10:30, and a verified calendar. Every scenario folds this history first, then its own givens.
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

final _created = MeetingTypeCreatedEvent(
  meetingTypeId: _type,
  hostId: _host,
  meetingTitle: MeetingTitle('30-minute consultation'),
  durationMinutes: DurationMinutes(30),
  meetingLocation: MeetingLocation('Video call'),
  scheduleId: _schedule,
  bookingUrl: BookingUrl('https://scheduler.example.com/alice/30-minute-consultation'),
);

final _fifteenMinuteCreated = MeetingTypeCreatedEvent(
  meetingTypeId: MeetingTypeId('meeting-type-15'),
  hostId: _host,
  meetingTitle: MeetingTitle('15-minute check-in'),
  durationMinutes: DurationMinutes(15),
  meetingLocation: MeetingLocation('Video call'),
  scheduleId: _schedule,
  bookingUrl: BookingUrl('https://scheduler.example.com/alice/15-minute-check-in'),
);

/// A booking of another meeting type of the host, already reserved.
MeetingSlotReservedEvent _reserved({
  MeetingId? meetingId,
  MeetingTypeId? meetingTypeId,
  DateTime? start,
  DateTime? end,
}) => MeetingSlotReservedEvent(
  meetingId: meetingId ?? _heldMeeting,
  hostId: _host,
  bookerId: BookerId('carol-employee-id'),
  meetingTypeId: meetingTypeId ?? _type,
  meetingTitle: MeetingTitle('30-minute consultation'),
  meetingLocation: MeetingLocation('Video call'),
  slotStart: SlotStart(start ?? _slotStart),
  slotEnd: SlotEnd(end ?? _slotEnd),
  participants: Participants([]),
);

MeetingRescheduleRequestedEvent _rescheduleRequested({required DateTime start, required DateTime end}) =>
    MeetingRescheduleRequestedEvent(
      meetingId: _heldMeeting,
      hostId: _host,
      requestedBy: RequestedBy('carol-employee-id'),
      newSlotStart: NewSlotStart(start),
      newSlotEnd: NewSlotEnd(end),
      calendarEventId: CalendarEventId('evt-1'),
      participants: Participants([]),
    );

ReserveMeetingSlotCommand _command({
  BookerId? bookerId,
  MeetingTypeId? meetingTypeId,
  DateTime? start,
  DateTime? end,
}) => ReserveMeetingSlotCommand(
  meetingId: _newMeeting,
  meetingTypeId: meetingTypeId ?? _type,
  hostId: _host,
  scheduleId: _schedule,
  bookerId: bookerId ?? _booker,
  bookerName: EmployeeName('Bob Example'),
  bookerEmail: EmployeeEmail('bob@example.com'),
  slotStart: start ?? _slotStart,
  slotEnd: end ?? _slotEnd,
  now: _now,
);

ReserveMeetingSlotState _fold(List<DomainEvent> history) =>
    history.fold(reserveMeetingSlotDecider.initialState, reserveMeetingSlotDecider.evolve);

/// The events the decider yields, or the refusal as text. Two equal outcomes are the same decision.
Future<Object> _outcome(ReserveMeetingSlotCommand command, ReserveMeetingSlotState state) async {
  try {
    return await reserveMeetingSlotDecider.decide(command, state).toList();
  } on ReserveMeetingSlotError catch (error) {
    return '${error.runtimeType}: ${error.message}';
  }
}

/// Matches a refusal of type [T] with the text of the model.
Matcher _refused<T extends ReserveMeetingSlotError>(String text) => isA<T>().having((e) => e.message, 'message', text);

/// Asserts that the decision on [command] given [history] is refused with [error], and yields nothing.
Future<void> _expectRefused(List<DomainEvent> history, ReserveMeetingSlotCommand command, Matcher error) async {
  final emitted = <DomainEvent>[];
  await expectLater(
    reserveMeetingSlotDecider.decide(command, _fold(history)).forEach(emitted.add),
    throwsA(error),
  );
  expect(emitted, isEmpty);
}

void main() {
  group('happy_path', () {
    // @requires host schedule open Monday 09:00-10:30 UTC, verified calendar, meeting type 30 minutes, slot free
    // @ensures scenario booker_reserves_a_free_slot: exactly meeting_slot_reserved for the command's slot
    test('booker_reserves_a_free_slot', () async {
      final events = await reserveMeetingSlotDecider.decide(_command(), _fold([..._base, _created])).toList();
      expect(events, hasLength(1));
      final reserved = events.single as MeetingSlotReservedEvent;
      expect(reserved.meetingId, _newMeeting);
      expect(reserved.hostId, _host);
      expect(reserved.bookerId, _booker);
      expect(reserved.slotStart.value, _slotStart);
      expect(reserved.slotEnd.value, _slotEnd);
      expect(reserved.participants.items.map((p) => p.role), ['host', 'booker']);
    });
  });

  group('state_violation', () {
    // @requires meeting_type_created; meeting_slot_reserved for the same slot by another meeting
    // @ensures scenario concurrent_booking_loses: refused with the model's text and emits nothing
    test('concurrent_booking_loses', () async {
      await _expectRefused(
        [..._base, _created, _reserved(meetingId: _heldMeeting)],
        _command(),
        _refused<SlotHeldError>('This time was just booked. Please choose another slot.'),
      );
    });

    // @requires meeting_type_created (15 minutes); meeting_slot_reserved of 09:00-10:00 for another meeting type
    // @ensures scenario overlap_across_meeting_types_is_refused: refused with the model's text and emits nothing
    test('overlap_across_meeting_types_is_refused', () async {
      await _expectRefused(
        [
          ..._base,
          _fifteenMinuteCreated,
          _reserved(
            meetingTypeId: MeetingTypeId('meeting-type-60'),
            start: _slotStart,
            end: DateTime.utc(2027, 3, 22, 10),
          ),
        ],
        _command(meetingTypeId: MeetingTypeId('meeting-type-15'), end: DateTime.utc(2027, 3, 22, 9, 15)),
        _refused<SlotHeldError>('This time was just booked. Please choose another slot.'),
      );
    });

    // @requires meeting_type_created; meeting_reschedule_requested to the slot
    // @ensures scenario slot_held_by_a_reschedule_is_refused: refused with the model's text and emits nothing
    test('slot_held_by_a_reschedule_is_refused', () async {
      await _expectRefused(
        [
          ..._base,
          _created,
          _reserved(meetingId: _heldMeeting, start: _laterStart, end: _laterEnd),
          _rescheduleRequested(start: _slotStart, end: _slotEnd),
        ],
        _command(),
        _refused<SlotHeldError>('This time was just booked. Please choose another slot.'),
      );
    });

    // @requires meeting_type_created; host_busy_times_recorded covering the slot
    // @ensures scenario slot_that_became_busy_is_refused: refused with the model's text and emits nothing
    test('slot_that_became_busy_is_refused', () async {
      await _expectRefused(
        [
          ..._base,
          _created,
          HostBusyTimesRecordedEvent(
            hostId: _host,
            busyIntervals: BusyIntervals([BusyInterval(busyFrom: _slotStart, busyUntil: _slotEnd)]),
          ),
        ],
        _command(),
        _refused<SlotBusyError>('This time is no longer available. Please choose another slot.'),
      );
    });

    // @requires meeting_type_created; meeting_type_disabled
    // @ensures scenario disabled_meeting_type_is_refused: refused with the model's text and emits nothing
    test('disabled_meeting_type_is_refused', () async {
      await _expectRefused(
        [..._base, _created, MeetingTypeDisabledEvent(meetingTypeId: _type)],
        _command(),
        _refused<MeetingTypeNotAcceptingError>('This meeting type is not accepting bookings.'),
      );
    });

    // @requires meeting_type_created; meeting_type_deleted
    // @ensures scenario deleted_meeting_type_is_refused: refused with the model's text and emits nothing
    test('deleted_meeting_type_is_refused', () async {
      await _expectRefused(
        [..._base, _created, MeetingTypeDeletedEvent(meetingTypeId: _type)],
        _command(),
        _refused<MeetingTypeNotAcceptingError>('This meeting type is not accepting bookings.'),
      );
    });
  });

  group('limit', () {
    // @requires booking_limits_set with a 1-day booking window; the slot is six days away
    // @ensures scenario slot_outside_the_rules_is_refused: refused with the model's text and emits nothing
    test('slot_outside_the_rules_is_refused', () async {
      await _expectRefused(
        [
          ..._base,
          BookingLimitsSetEvent(
            scheduleId: _schedule,
            bookingWindowDays: BookingWindowDays(1),
            minimumNoticeMinutes: MinimumNoticeMinutes(0),
            bufferBeforeMinutes: BufferBeforeMinutes(0),
            bufferAfterMinutes: BufferAfterMinutes(0),
          ),
          _created,
        ],
        _command(),
        _refused<SlotOutsideRulesError>(
          "This time is outside the host's booking rules. Please choose another slot.",
        ),
      );
    });
  });

  group('external_failure', () {
    // @requires meeting_type_created; calendar_connection_failed
    // @ensures scenario unverified_calendar_is_refused: refused with the model's text and emits nothing
    test('unverified_calendar_is_refused', () async {
      await _expectRefused(
        [
          ..._base,
          _created,
          CalendarConnectionFailedEvent(hostId: _host, connectionFailure: ConnectionFailure('Consent was denied')),
        ],
        _command(),
        _refused<CalendarUnverifiedError>(
          "The host's availability cannot be verified right now. Please try again later.",
        ),
      );
    });
  });

  group('authorization', () {
    // @requires meeting_type_created by alice; the command comes from alice herself
    // @ensures scenario host_cannot_book_their_own_link: refused with the model's text and emits nothing
    test('host_cannot_book_their_own_link', () async {
      await _expectRefused(
        [..._base, _created],
        _command(bookerId: BookerId(_host.value)),
        _refused<SelfBookingError>('You cannot book a meeting with yourself.'),
      );
    });

    // The model's `unauthenticated_booking_is_refused` has no decider form: a command always names its booker
    // (`BookerId` is never empty). The application refuses anonymous posts before the decider runs, by sending
    // them to sign-in; `test/slices/reserve_meeting_slot/module_test.dart` covers that.
  });

  group('release', () {
    // @requires a reserved slot that the meeting then releases (booking failed, canceled, or completed)
    // @ensures the released slot is free again, so the same slot decides like a free slot
    for (final release in <DomainEvent>[
      MeetingBookingFailedEvent(meetingId: _heldMeeting, failureReason: FailureReason('The host is busy at that time')),
      MeetingCanceledEvent(meetingId: _heldMeeting),
      MeetingCompletedEvent(meetingId: _heldMeeting),
    ]) {
      test('${release.runtimeType}_releases_the_slot', () async {
        final events = await reserveMeetingSlotDecider
            .decide(_command(), _fold([..._base, _created, _reserved(), release]))
            .toList();
        expect(events, hasLength(1));
      });
    }

    // @requires a reserved slot that a reschedule moved to a later, free slot
    // @ensures the new slot is held after the reschedule, and the old slot is free
    test('rescheduled_meeting_holds_only_its_new_slot', () async {
      final history = [
        ..._base,
        _created,
        _reserved(),
        _rescheduleRequested(start: _laterStart, end: _laterEnd),
        MeetingRescheduledEvent(meetingId: _heldMeeting),
      ];
      final events = await reserveMeetingSlotDecider.decide(_command(), _fold(history)).toList();
      expect(events, hasLength(1));
      await _expectRefused(
        history,
        _command(start: _laterStart, end: _laterEnd),
        _refused<SlotHeldError>('This time was just booked. Please choose another slot.'),
      );
    });

    // @requires a reserved slot with a pending reschedule that then fails
    // @ensures the pending slot is released; the current slot stays held
    test('failed_reschedule_releases_the_pending_slot', () async {
      final history = [
        ..._base,
        _created,
        _reserved(),
        _rescheduleRequested(start: _laterStart, end: _laterEnd),
        MeetingRescheduleFailedEvent(meetingId: _heldMeeting, failureReason: FailureReason('The host is busy')),
      ];
      final events = await reserveMeetingSlotDecider
          .decide(_command(start: _laterStart, end: _laterEnd), _fold(history))
          .toList();
      expect(events, hasLength(1));
      await _expectRefused(
        history,
        _command(),
        _refused<SlotHeldError>('This time was just booked. Please choose another slot.'),
      );
    });

    // @requires a reserved slot that the calendar moved directly to a later slot
    // @ensures the moved-to slot is held, and the old slot is free
    test('moved_in_calendar_holds_the_moved_slot', () async {
      final history = [
        ..._base,
        _created,
        _reserved(),
        MeetingMovedInCalendarEvent(
          meetingId: _heldMeeting,
          newSlotStart: NewSlotStart(_laterStart),
          newSlotEnd: NewSlotEnd(_laterEnd),
        ),
      ];
      final events = await reserveMeetingSlotDecider.decide(_command(), _fold(history)).toList();
      expect(events, hasLength(1));
      await _expectRefused(
        history,
        _command(start: _laterStart, end: _laterEnd),
        _refused<SlotHeldError>('This time was just booked. Please choose another slot.'),
      );
    });
  });

  group('property_laws', () {
    final scenarios = <(List<DomainEvent>, ReserveMeetingSlotCommand)>[
      ([..._base, _created], _command()),
      ([..._base, _created, _reserved(meetingId: _heldMeeting)], _command()),
      ([..._base, _created, _rescheduleRequested(start: _slotStart, end: _slotEnd)], _command()),
      ([..._base, _created, MeetingTypeDeletedEvent(meetingTypeId: _type)], _command()),
      (
        [
          ..._base,
          _created,
          _reserved(),
          MeetingBookingFailedEvent(meetingId: _heldMeeting, failureReason: FailureReason('x')),
        ],
        _command(),
      ),
    ];

    // @requires state == fold(initialState, history) for each scenario history
    // @ensures deciding the same command on the same state always yields the same outcome
    test('decide_after_fold_is_deterministic', () async {
      for (final (history, command) in scenarios) {
        final state = _fold(history);
        expect(await _outcome(command, state), await _outcome(command, state));
      }
    });

    // @requires any split point i of a history
    // @ensures folding the history in two parts gives the same decision as folding it whole
    test('fold_over_a_split_equals_fold_over_the_whole', () async {
      for (final (history, command) in scenarios) {
        final whole = await _outcome(command, _fold(history));
        for (var i = 0; i <= history.length; i++) {
          final partial = _fold(history.sublist(0, i));
          final split = history.sublist(i).fold(partial, reserveMeetingSlotDecider.evolve);
          expect(await _outcome(command, split), whole, reason: 'split at $i');
        }
      }
    });

    // @requires a refused scenario history
    // @ensures a refusal emits no event
    test('error_scenarios_emit_nothing', () async {
      for (final (history, command) in scenarios) {
        final outcome = await _outcome(command, _fold(history));
        if (outcome is! String) continue;
        final emitted = await reserveMeetingSlotDecider
            .decide(command, _fold(history))
            .toList()
            .catchError((_) => <DomainEvent>[]);
        expect(emitted, isEmpty, reason: outcome);
      }
    });
  });
}
