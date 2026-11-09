import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/create_availability_schedule/command.dart';
import 'package:em_calendly_example/slices/create_availability_schedule/decider.dart';
import 'package:em_calendly_example/slices/create_availability_schedule/state.dart';
import 'package:test/test.dart';

final _schedule = ScheduleId('schedule-1');
final _host = HostId('alice-employee-id');
final _command = CreateAvailabilityScheduleCommand(
  scheduleId: _schedule,
  hostId: _host,
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);
final _created = AvailabilityScheduleCreatedEvent(
  scheduleId: _schedule,
  hostId: _host,
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);
final _bookingLimits = BookingLimitsSetEvent(
  scheduleId: _schedule,
  bookingWindowDays: BookingWindowDays(30),
  minimumNoticeMinutes: MinimumNoticeMinutes(60),
  bufferBeforeMinutes: BufferBeforeMinutes(0),
  bufferAfterMinutes: BufferAfterMinutes(0),
);

CreateAvailabilityScheduleState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(createAvailabilityScheduleDecider.initialState, createAvailabilityScheduleDecider.evolve);

void main() {
  group('happy_path', () {
    // @requires no availability_schedule events for the schedule id
    // @ensures scenario host_creates_a_schedule: exactly availability_schedule_created with the command's fields
    test('host_creates_a_schedule', () async {
      final events = await createAvailabilityScheduleDecider.decide(_command, _foldHistory([])).toList();
      expect(events, [_created]);
    });
  });

  // Model gap: no invalid transition or scenario names an existing schedule for this command, so the decider accepts.
  group('model_gap', () {
    // @requires the schedule is already defined (state defined)
    // @ensures the model states no rule, so the decider accepts the command and emits created again (see the report)
    test('defined_schedule_accepts_the_command_no_model_rule', () async {
      final events = await createAvailabilityScheduleDecider.decide(_command, _foldHistory([_created])).toList();
      expect(events, [_created]);
    });
  });

  group('lifecycle_evolve', () {
    // @requires any history of the availability_schedule events
    // @ensures evolve maps each event of the lifecycle to the defined state
    test('evolve sets defined for each event of the lifecycle', () {
      final decider = createAvailabilityScheduleDecider;
      expect(
        decider.evolve(decider.initialState, _created),
        const CreateAvailabilityScheduleState(lifecycle: AvailabilityScheduleLifecycleState.defined),
      );
      expect(
        decider.evolve(decider.initialState, _bookingLimits),
        const CreateAvailabilityScheduleState(lifecycle: AvailabilityScheduleLifecycleState.defined),
      );
    });
  });

  // Property laws over every history the model can produce for this command.
  final histories = <List<HostSetupEvent>>[
    [],
    [_created],
    [_created, _bookingLimits],
    [_bookingLimits],
  ];

  // @requires any history
  // @ensures decide yields exactly one created event carrying the command's fields, in every state
  test('decide yields one created event in every state', () async {
    for (final history in histories) {
      final state = _foldHistory(history);
      final events = await createAvailabilityScheduleDecider.decide(_command, state).toList();
      expect(events, [_created], reason: 'history $history');
    }
  });

  // @requires any history
  // @ensures decide is deterministic: two decisions on the same state give equal events
  test('decide is deterministic', () async {
    for (final history in histories) {
      final state = _foldHistory(history);
      final first = await createAvailabilityScheduleDecider.decide(_command, state).toList();
      final second = await createAvailabilityScheduleDecider.decide(_command, state).toList();
      expect(second, first, reason: 'history $history');
    }
  });

  // @requires any two histories split at any point
  // @ensures folding a then b equals folding b after the fold of a
  test('fold preserves order', () {
    final decider = createAvailabilityScheduleDecider;
    final history = [_created, _bookingLimits];
    for (var i = 0; i <= history.length; i++) {
      final a = history.sublist(0, i);
      final b = history.sublist(i);
      final whole = [...a, ...b].fold(decider.initialState, decider.evolve);
      final stepwise = b.fold(a.fold(decider.initialState, decider.evolve), decider.evolve);
      expect(stepwise, whole);
    }
  });

  // @requires any two commands
  // @ensures equal fields give equal commands with equal hash codes, and a different schedule id gives an unequal one
  test('command equality and hashCode', () {
    final same = CreateAvailabilityScheduleCommand(
      scheduleId: ScheduleId(_schedule.value),
      hostId: HostId(_host.value),
      scheduleName: ScheduleName('Working hours'),
      timeZone: TimeZone('Europe/Berlin'),
    );
    expect(same, equals(_command));
    expect(same.hashCode, _command.hashCode);
    final other = CreateAvailabilityScheduleCommand(
      scheduleId: ScheduleId('schedule-2'),
      hostId: _host,
      scheduleName: ScheduleName('Working hours'),
      timeZone: TimeZone('Europe/Berlin'),
    );
    expect(other, isNot(equals(_command)));
  });

  // @requires any two states
  // @ensures equal lifecycles give equal states with equal hash codes
  test('state equality and hashCode', () {
    for (final lifecycle in [null, ...AvailabilityScheduleLifecycleState.values]) {
      final a = CreateAvailabilityScheduleState(lifecycle: lifecycle);
      final b = CreateAvailabilityScheduleState(lifecycle: lifecycle);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    }
  });
}
