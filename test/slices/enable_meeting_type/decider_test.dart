import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/enable_meeting_type/command.dart';
import 'package:em_calendly_example/slices/enable_meeting_type/decider.dart';
import 'package:em_calendly_example/slices/enable_meeting_type/errors.dart';
import 'package:em_calendly_example/slices/enable_meeting_type/state.dart';
import 'package:test/test.dart';

final _host = HostId('alice-employee-id');
final _meetingType = MeetingTypeId('meeting-type-1');
final _command = EnableMeetingTypeCommand(meetingTypeId: _meetingType, hostId: _host);
final _created = MeetingTypeCreatedEvent(
  meetingTypeId: _meetingType,
  hostId: _host,
  meetingTitle: MeetingTitle('30-minute consultation'),
  durationMinutes: DurationMinutes(30),
  meetingLocation: MeetingLocation('Room 4'),
  scheduleId: ScheduleId('schedule-1'),
  bookingUrl: BookingUrl('http://scheduler.test/book/meeting-type-1'),
);
final _disabled = MeetingTypeDisabledEvent(meetingTypeId: _meetingType);
final _enabled = MeetingTypeEnabledEvent(meetingTypeId: _meetingType);
final _deleted = MeetingTypeDeletedEvent(meetingTypeId: _meetingType);

EnableMeetingTypeState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(enableMeetingTypeDecider.initialState, enableMeetingTypeDecider.evolve);

void main() {
  group('happy_path', () {
    // @requires meeting_type_created by the host, meeting_type_disabled; lifecycle disabled
    // @ensures scenario host_enables_a_disabled_meeting_type: exactly meeting_type_enabled with the command's meeting type
    test('host_enables_a_disabled_meeting_type', () async {
      final events = await enableMeetingTypeDecider.decide(_command, _foldHistory([_created, _disabled])).toList();
      expect(events, [_enabled]);
    });
  });

  group('state_violation', () {
    // @requires meeting_type_deleted in the history (the scenario gives no creation event)
    // @ensures the decider refuses with the model text of invalid_transition enable_deleted and emits nothing
    test('deleted_meeting_type_cannot_be_enabled', () async {
      final emitted = <HostSetupEvent>[];
      await expectLater(
        enableMeetingTypeDecider.decide(_command, _foldHistory([_deleted])).forEach(emitted.add),
        throwsA(
          isA<MeetingTypeDeletedCannotBeEnabledError>().having(
            (error) => error.message,
            'message',
            'A deleted meeting type cannot be enabled.',
          ),
        ),
      );
      expect(emitted, isEmpty);
    });

    // @requires meeting_type_created, meeting_type_disabled, then meeting_type_deleted
    // @ensures the decider refuses with the model text of invalid_transition enable_deleted
    test('deleted_after_disable_cannot_be_enabled', () async {
      await expectLater(
        enableMeetingTypeDecider.decide(_command, _foldHistory([_created, _disabled, _deleted])).toList(),
        throwsA(isA<MeetingTypeDeletedCannotBeEnabledError>()),
      );
    });
  });

  // Derived rule (not in the model): only the host of the meeting type may enable it (the same check as disable).
  group('derived_rule', () {
    // @requires meeting_type_created by alice, meeting_type_disabled; the command comes from bob
    // @ensures the decider refuses with NotMeetingTypeHostError and emits nothing
    test('enable_by_another_host_is_refused', () async {
      final bobsCommand = EnableMeetingTypeCommand(meetingTypeId: _meetingType, hostId: HostId('bob-employee-id'));
      final emitted = <HostSetupEvent>[];
      await expectLater(
        enableMeetingTypeDecider.decide(bobsCommand, _foldHistory([_created, _disabled])).forEach(emitted.add),
        throwsA(isA<NotMeetingTypeHostError>()),
      );
      expect(emitted, isEmpty);
    });

    // @requires no meeting_type_created for the meeting type
    // @ensures the decider refuses with NotMeetingTypeHostError and emits nothing
    test('enable_of_a_missing_meeting_type_is_refused', () async {
      await expectLater(
        enableMeetingTypeDecider.decide(_command, _foldHistory(const [])).toList(),
        throwsA(isA<NotMeetingTypeHostError>()),
      );
    });
  });

  group('property_laws', () {
    // @requires state == fold(initialState, given)
    // @ensures decide(command, state) is deterministic: two calls emit the same events
    test('decide_after_fold_is_deterministic', () async {
      final state = _foldHistory([_created, _disabled]);
      final first = await enableMeetingTypeDecider.decide(_command, state).toList();
      final second = await enableMeetingTypeDecider.decide(_command, state).toList();
      expect(first, [_enabled]);
      expect(second, first);
    });

    // @ensures fold(s0, a ++ b) == fold(fold(s0, a), b)
    test('fold_preserves_order', () {
      final decider = enableMeetingTypeDecider;
      final history = <HostSetupEvent>[_created, _disabled, _enabled, _disabled];
      for (var split = 0; split <= history.length; split++) {
        final a = history.sublist(0, split);
        final b = history.sublist(split);
        final whole = [...a, ...b].fold(decider.initialState, decider.evolve);
        final stepwise = b.fold(a.fold(decider.initialState, decider.evolve), decider.evolve);
        expect(stepwise, whole);
      }
    });

    // @requires state == fold(initialState, given), host of the meeting type is the command's host
    // @ensures the emitted event names the command's meeting type and nothing else
    test('emitted_event_names_the_command_meeting_type', () async {
      final otherType = MeetingTypeId('meeting-type-2');
      final command = EnableMeetingTypeCommand(meetingTypeId: otherType, hostId: _host);
      final events = await enableMeetingTypeDecider.decide(command, _foldHistory([_created, _disabled])).toList();
      expect(events, [MeetingTypeEnabledEvent(meetingTypeId: otherType)]);
    });

    // @ensures evolve(state, meeting_type_enabled) keeps the host and sets the lifecycle to active
    test('evolve_after_enable_marks_the_meeting_type_active', () {
      final state = enableMeetingTypeDecider.evolve(_foldHistory([_created, _disabled]), _enabled);
      expect(state, EnableMeetingTypeState(lifecycle: MeetingTypeLifecycleState.active, hostId: _host));
    });
  });
}
