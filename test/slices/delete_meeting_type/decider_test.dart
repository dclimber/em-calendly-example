import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/delete_meeting_type/command.dart';
import 'package:em_calendly_example/slices/delete_meeting_type/decider.dart';
import 'package:em_calendly_example/slices/delete_meeting_type/errors.dart';
import 'package:em_calendly_example/slices/delete_meeting_type/state.dart';
import 'package:test/test.dart';

final _host = HostId('alice-employee-id');
final _meetingType = MeetingTypeId('meeting-type-1');
final _command = DeleteMeetingTypeCommand(meetingTypeId: _meetingType, hostId: _host);
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
final _enabled = MeetingTypeEnabledEvent(meetingTypeId: _meetingType);
final _deleted = MeetingTypeDeletedEvent(meetingTypeId: _meetingType);

DeleteMeetingTypeState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(deleteMeetingTypeDecider.initialState, deleteMeetingTypeDecider.evolve);

void main() {
  group('happy_path', () {
    // @requires meeting_type_created by the host; lifecycle active
    // @ensures scenario host_deletes_a_meeting_type: exactly meeting_type_deleted with the command's meeting type
    test('host_deletes_a_meeting_type', () async {
      final events = await deleteMeetingTypeDecider.decide(_command, _foldHistory([_created])).toList();
      expect(events, [_deleted]);
    });
  });

  group('variant', () {
    // @requires meeting_type_created by the host; the scenario's meeting_confirmed is a meetings event that the decider does not read
    // @ensures scenario delete_leaves_upcoming_meetings_in_place: exactly meeting_type_deleted; the meeting is not touched
    test('delete_leaves_upcoming_meetings_in_place', () async {
      final events = await deleteMeetingTypeDecider.decide(_command, _foldHistory([_created])).toList();
      expect(events, [_deleted]);
    });

    // @requires meeting_type_created by the host, meeting_type_disabled; lifecycle disabled
    // @ensures the host's delete of a disabled meeting type emits exactly meeting_type_deleted (transition delete)
    test('host_deletes_a_disabled_meeting_type', () async {
      final events = await deleteMeetingTypeDecider.decide(_command, _foldHistory([_created, _disabled])).toList();
      expect(events, [_deleted]);
    });

    // @requires meeting_type_created, meeting_type_disabled, meeting_type_enabled; lifecycle active
    // @ensures the host's delete of a re-enabled meeting type emits exactly meeting_type_deleted
    test('host_deletes_a_re_enabled_meeting_type', () async {
      final events = await deleteMeetingTypeDecider
          .decide(_command, _foldHistory([_created, _disabled, _enabled]))
          .toList();
      expect(events, [_deleted]);
    });
  });

  // Derived rule (not in the model): only the host of the meeting type may delete it (the same check as the siblings).
  group('derived_rule', () {
    // @requires meeting_type_created by alice; the command comes from bob
    // @ensures the decider refuses with NotMeetingTypeHostError and emits nothing
    test('delete_by_another_host_is_refused', () async {
      final bobsCommand = DeleteMeetingTypeCommand(meetingTypeId: _meetingType, hostId: HostId('bob-employee-id'));
      final emitted = <HostSetupEvent>[];
      await expectLater(
        deleteMeetingTypeDecider.decide(bobsCommand, _foldHistory([_created])).forEach(emitted.add),
        throwsA(isA<NotMeetingTypeHostError>()),
      );
      expect(emitted, isEmpty);
    });

    // @requires no meeting_type_created for the meeting type
    // @ensures the decider refuses with NotMeetingTypeHostError and emits nothing
    test('delete_of_a_missing_meeting_type_is_refused', () async {
      await expectLater(
        deleteMeetingTypeDecider.decide(_command, _foldHistory(const [])).toList(),
        throwsA(isA<NotMeetingTypeHostError>()),
      );
    });
  });

  group('property_laws', () {
    // @requires state == fold(initialState, given)
    // @ensures decide(command, state) is deterministic: two calls emit the same events
    test('decide_after_fold_is_deterministic', () async {
      final state = _foldHistory([_created]);
      final first = await deleteMeetingTypeDecider.decide(_command, state).toList();
      final second = await deleteMeetingTypeDecider.decide(_command, state).toList();
      expect(first, [_deleted]);
      expect(second, first);
    });

    // @ensures fold(s0, a ++ b) == fold(fold(s0, a), b)
    test('fold_preserves_order', () {
      final decider = deleteMeetingTypeDecider;
      final history = <HostSetupEvent>[_created, _disabled, _enabled, _deleted];
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
      final command = DeleteMeetingTypeCommand(meetingTypeId: otherType, hostId: _host);
      final events = await deleteMeetingTypeDecider.decide(command, _foldHistory([_created])).toList();
      expect(events, [MeetingTypeDeletedEvent(meetingTypeId: otherType)]);
    });

    // @ensures evolve(state, meeting_type_deleted) keeps the host and sets the lifecycle to deleted
    test('evolve_after_delete_marks_the_meeting_type_deleted', () {
      final state = deleteMeetingTypeDecider.evolve(_foldHistory([_created]), _deleted);
      expect(state, DeleteMeetingTypeState(lifecycle: MeetingTypeLifecycleState.deleted, hostId: _host));
    });
  });
}
