import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/disable_meeting_type/command.dart';
import 'package:em_calendly_example/slices/disable_meeting_type/decider.dart';
import 'package:em_calendly_example/slices/disable_meeting_type/errors.dart';
import 'package:em_calendly_example/slices/disable_meeting_type/state.dart';
import 'package:test/test.dart';

final _host = HostId('alice-employee-id');
final _meetingType = MeetingTypeId('meeting-type-1');
final _command = DisableMeetingTypeCommand(meetingTypeId: _meetingType, hostId: _host);
final _created = MeetingTypeCreatedEvent(
  meetingTypeId: _meetingType,
  hostId: _host,
  meetingTitle: MeetingTitle('30-minute consultation'),
  durationMinutes: DurationMinutes(30),
  meetingLocation: MeetingLocation('Room 4'),
  scheduleId: ScheduleId('schedule-1'),
  bookingUrl: BookingUrl('http://scheduler.test/app/book/meeting-type-1'),
);
final _disabled = MeetingTypeDisabledEvent(meetingTypeId: _meetingType);

DisableMeetingTypeState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(disableMeetingTypeDecider.initialState, disableMeetingTypeDecider.evolve);

void main() {
  group('happy_path', () {
    // @requires meeting_type_created by the host, lifecycle active
    // @ensures scenario host_disables_a_meeting_type: exactly meeting_type_disabled with the command's meeting type
    test('host_disables_a_meeting_type', () async {
      final events = await disableMeetingTypeDecider.decide(_command, _foldHistory([_created])).toList();
      expect(events, [_disabled]);
    });
  });

  // Derived rule (not in the model): only the host of the meeting type may disable it (the same check as edit).
  group('derived_rule', () {
    // @requires meeting_type_created by alice; the command comes from bob
    // @ensures the decider refuses with NotMeetingTypeHostError and emits nothing
    test('disable_by_another_host_is_refused', () async {
      final bobsCommand = DisableMeetingTypeCommand(meetingTypeId: _meetingType, hostId: HostId('bob-employee-id'));
      final emitted = <HostSetupEvent>[];
      await expectLater(
        disableMeetingTypeDecider.decide(bobsCommand, _foldHistory([_created])).forEach(emitted.add),
        throwsA(isA<NotMeetingTypeHostError>()),
      );
      expect(emitted, isEmpty);
    });

    // @requires no meeting_type_created for the meeting type
    // @ensures the decider refuses with NotMeetingTypeHostError and emits nothing
    test('disable_of_a_missing_meeting_type_is_refused', () async {
      await expectLater(
        disableMeetingTypeDecider.decide(_command, _foldHistory(const [])).toList(),
        throwsA(isA<NotMeetingTypeHostError>()),
      );
    });
  });

  group('property_laws', () {
    // @requires state == fold(initialState, given)
    // @ensures decide(command, state) is deterministic: two calls emit the same events
    test('decide_after_fold_is_deterministic', () async {
      final state = _foldHistory([_created]);
      final first = await disableMeetingTypeDecider.decide(_command, state).toList();
      final second = await disableMeetingTypeDecider.decide(_command, state).toList();
      expect(first, [_disabled]);
      expect(second, first);
    });

    // @ensures fold(s0, a ++ b) == fold(fold(s0, a), b)
    test('fold_preserves_order', () {
      final decider = disableMeetingTypeDecider;
      final history = <HostSetupEvent>[_created, _disabled, MeetingTypeEnabledEvent(meetingTypeId: _meetingType)];
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
      final command = DisableMeetingTypeCommand(meetingTypeId: otherType, hostId: _host);
      final events = await disableMeetingTypeDecider.decide(command, _foldHistory([_created])).toList();
      expect(events, [MeetingTypeDisabledEvent(meetingTypeId: otherType)]);
    });

    // @ensures evolve(state, meeting_type_disabled) keeps the host and sets the lifecycle to disabled
    test('evolve_after_disable_marks_the_meeting_type_disabled', () {
      final state = disableMeetingTypeDecider.evolve(_foldHistory([_created]), _disabled);
      expect(state, DisableMeetingTypeState(lifecycle: MeetingTypeLifecycleState.disabled, hostId: _host));
    });
  });
}
