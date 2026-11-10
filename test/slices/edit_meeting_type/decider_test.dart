import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/edit_meeting_type/command.dart';
import 'package:em_calendly_example/slices/edit_meeting_type/decider.dart';
import 'package:em_calendly_example/slices/edit_meeting_type/errors.dart';
import 'package:em_calendly_example/slices/edit_meeting_type/state.dart';
import 'package:test/test.dart';

final _host = HostId('alice-employee-id');
final _meetingType = MeetingTypeId('meeting-type-1');
final _schedule = ScheduleId('schedule-1');
final _command = EditMeetingTypeCommand(
  meetingTypeId: _meetingType,
  hostId: _host,
  meetingTitle: MeetingTitle('60-minute consultation'),
  durationMinutes: DurationMinutes(60),
  meetingLocation: MeetingLocation('Room 5'),
  scheduleId: _schedule,
  meetingDescription: MeetingDescription('Longer slot'),
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
final _edited = MeetingTypeEditedEvent(
  meetingTypeId: _meetingType,
  meetingTitle: MeetingTitle('60-minute consultation'),
  durationMinutes: DurationMinutes(60),
  meetingLocation: MeetingLocation('Room 5'),
  scheduleId: _schedule,
  meetingDescription: MeetingDescription('Longer slot'),
);

EditMeetingTypeState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(editMeetingTypeDecider.initialState, editMeetingTypeDecider.evolve);

void main() {
  group('happy_path', () {
    // @requires meeting_type_created by the host, lifecycle active
    // @ensures scenario host_edits_a_meeting_type: exactly meeting_type_edited with the command's fields
    test('host_edits_a_meeting_type', () async {
      final events = await editMeetingTypeDecider.decide(_command, _foldHistory([_created])).toList();
      expect(events, [_edited]);
    });

    // @requires meeting_type_created, then meeting_type_disabled
    // @ensures transition edit_disabled: the edit is recorded and the meeting type stays disabled
    test('disabled_meeting_type_can_be_edited', () async {
      final events = await editMeetingTypeDecider
          .decide(_command, _foldHistory([_created, MeetingTypeDisabledEvent(meetingTypeId: _meetingType)]))
          .toList();
      expect(events, [_edited]);
    });
  });

  group('state_violation', () {
    // @requires meeting_type_created, then meeting_type_deleted
    // @ensures scenario deleted_meeting_type_cannot_be_edited: refused with the model's text, no events
    test('deleted_meeting_type_cannot_be_edited', () async {
      expect(
        () => editMeetingTypeDecider
            .decide(_command, _foldHistory([_created, MeetingTypeDeletedEvent(meetingTypeId: _meetingType)]))
            .toList(),
        throwsA(
          isA<MeetingTypeDeletedError>().having(
            (e) => e.message,
            'message',
            'A deleted meeting type cannot be edited.',
          ),
        ),
      );
    });
  });

  // Derived rule (not in the model): only the host of the meeting type may edit it.
  group('derived_rule', () {
    // @requires meeting_type_created by another host
    // @ensures the decider refuses with NotMeetingTypeHostError and emits nothing
    test('edit_by_another_host_is_refused', () async {
      final bobsCommand = EditMeetingTypeCommand(
        meetingTypeId: _meetingType,
        hostId: HostId('bob-employee-id'),
        meetingTitle: MeetingTitle('60-minute consultation'),
        durationMinutes: DurationMinutes(60),
        meetingLocation: MeetingLocation('Room 5'),
        scheduleId: _schedule,
      );
      expect(
        () => editMeetingTypeDecider.decide(bobsCommand, _foldHistory([_created])).toList(),
        throwsA(isA<NotMeetingTypeHostError>()),
      );
    });
  });
}
