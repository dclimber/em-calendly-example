import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/create_meeting_type/command.dart';
import 'package:em_calendly_example/slices/create_meeting_type/decider.dart';
import 'package:em_calendly_example/slices/create_meeting_type/errors.dart';
import 'package:em_calendly_example/slices/create_meeting_type/state.dart';
import 'package:test/test.dart';

final _host = HostId('alice-employee-id');
final _schedule = ScheduleId('schedule-1');
final _meetingType = MeetingTypeId('meeting-type-1');
final _command = CreateMeetingTypeCommand(
  meetingTypeId: _meetingType,
  hostId: _host,
  meetingTitle: MeetingTitle('30-minute consultation'),
  durationMinutes: DurationMinutes(30),
  meetingLocation: MeetingLocation('Room 4'),
  scheduleId: _schedule,
  bookingUrl: BookingUrl('http://scheduler.test/app/book/meeting-type-1'),
);
final _scheduleCreated = AvailabilityScheduleCreatedEvent(
  scheduleId: _schedule,
  hostId: _host,
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);
final _created = MeetingTypeCreatedEvent(
  meetingTypeId: _meetingType,
  hostId: _host,
  meetingTitle: MeetingTitle('30-minute consultation'),
  durationMinutes: DurationMinutes(30),
  meetingLocation: MeetingLocation('Room 4'),
  scheduleId: _schedule,
  bookingUrl: BookingUrl('http://scheduler.test/app/book/meeting-type-1'),
);

CreateMeetingTypeState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(createMeetingTypeDecider.initialState, createMeetingTypeDecider.evolve);

void main() {
  group('happy_path', () {
    // @requires availability_schedule_created for the command's schedule, owned by the host
    // @ensures scenario host_creates_a_meeting_type: exactly meeting_type_created with the command's fields
    test('host_creates_a_meeting_type', () async {
      final events = await createMeetingTypeDecider.decide(_command, _foldHistory([_scheduleCreated])).toList();
      expect(events, [_created]);
    });
  });

  group('refused_input', () {
    // @requires no availability_schedule_created for the command's schedule
    // @ensures scenario schedule_must_exist: the decider refuses with the model's error text
    test('schedule_must_exist', () async {
      expect(
        () => createMeetingTypeDecider.decide(_command, _foldHistory([])).toList(),
        throwsA(
          isA<MeetingTypeScheduleMissingError>().having(
            (e) => e.message,
            'message',
            'Choose an availability schedule for this meeting type.',
          ),
        ),
      );
    });
  });

  // Derived rule (not in the model): a schedule owned by another host counts as not chosen.
  group('derived_rule', () {
    // @requires availability_schedule_created for the command's schedule, owned by another host
    // @ensures the decider refuses with the same error as schedule_must_exist
    test('schedule_of_another_host_is_refused', () async {
      final bobsSchedule = AvailabilityScheduleCreatedEvent(
        scheduleId: _schedule,
        hostId: HostId('bob-employee-id'),
        scheduleName: ScheduleName('Working hours'),
        timeZone: TimeZone('Europe/Berlin'),
      );
      expect(
        () => createMeetingTypeDecider.decide(_command, _foldHistory([bobsSchedule])).toList(),
        throwsA(isA<MeetingTypeScheduleMissingError>()),
      );
    });
  });

  // Model gap: no invalid transition or scenario names an existing meeting type for this command, so the decider accepts.
  group('model_gap', () {
    // @requires the meeting type is already created (state active)
    // @ensures the model states no rule, so the decider accepts the command and emits meeting_type_created again
    test('existing_meeting_type_accepts_the_command_no_model_rule', () async {
      final events = await createMeetingTypeDecider
          .decide(_command, _foldHistory([_scheduleCreated, _created]))
          .toList();
      expect(events, [_created]);
    });
  });

  group('lifecycle_evolve', () {
    // @requires any history of the meeting_type events
    // @ensures evolve maps each event of the lifecycle to its state, and keeps the schedule owner
    test('evolve maps the meeting type lifecycle', () {
      final decider = createMeetingTypeDecider;
      final owned = CreateMeetingTypeState(scheduleOwner: _host);
      expect(
        decider.evolve(owned, _created),
        CreateMeetingTypeState(lifecycle: MeetingTypeLifecycleState.active, scheduleOwner: _host),
      );
      expect(
        decider.evolve(owned, MeetingTypeDisabledEvent(meetingTypeId: _meetingType)),
        CreateMeetingTypeState(lifecycle: MeetingTypeLifecycleState.disabled, scheduleOwner: _host),
      );
      expect(
        decider.evolve(owned, MeetingTypeDeletedEvent(meetingTypeId: _meetingType)),
        CreateMeetingTypeState(lifecycle: MeetingTypeLifecycleState.deleted, scheduleOwner: _host),
      );
    });
  });

  // Property laws over every history the model can produce for this command.
  final histories = <List<HostSetupEvent>>[
    [],
    [_scheduleCreated],
    [_scheduleCreated, _created],
  ];

  // @requires any history
  // @ensures decide yields exactly one meeting_type_created carrying the command's fields, or refuses the schedule
  test('decide yields one created event or the schedule refusal in every state', () async {
    for (final history in histories) {
      final state = _foldHistory(history);
      if (state.scheduleOwner == _host) {
        final events = await createMeetingTypeDecider.decide(_command, state).toList();
        expect(events, hasLength(1));
        expect(events.single, isA<MeetingTypeCreatedEvent>());
      } else {
        expect(
          () => createMeetingTypeDecider.decide(_command, state).toList(),
          throwsA(isA<MeetingTypeScheduleMissingError>()),
        );
      }
    }
  });

  // @requires any history
  // @ensures folding the same history twice gives the same state (evolve is deterministic)
  test('evolve is deterministic over every history', () {
    for (final history in histories) {
      expect(_foldHistory(history), _foldHistory(history));
    }
  });
}
