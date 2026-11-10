import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/confirm_booked_meeting/created_calendar_events/state.dart';
import 'package:em_calendly_example/slices/confirm_booked_meeting/processor_state.dart';
import 'package:em_calendly_example/slices/confirm_booked_meeting/saga.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

CreatedCalendarEventState _item({String meetingId = 'meeting-1', String calendarEventId = 'cal-1'}) =>
    CreatedCalendarEventState(meetingId: MeetingId(meetingId), calendarEventId: CalendarEventId(calendarEventId));

void main() {
  // @requires a listed calendar event with no recorded confirmation for its meeting
  // @ensures scenario translator_confirms_the_meeting: the processor emits one confirm_meeting command
  test('translator_confirms_the_meeting', () async {
    final commands = await calendarCreatedTranslatorSaga.react((
      recorded: const RecordedCalendarEventsState(),
      item: _item(),
    )).toList();
    expect(commands, [commandFor('meeting-1')]);
  });

  // @requires a listed calendar event whose calendar id the meeting already recorded as confirmed
  // @ensures the processor sends no command for the repeated event
  test('a repeated calendar event sends no command', () async {
    final recorded = recordedCalendarEventsView.evolve(
      recordedCalendarEventsView.initialState,
      MeetingConfirmedEvent(meetingId: MeetingId('meeting-1'), calendarEventId: CalendarEventId('cal-1')),
    );
    final commands = await calendarCreatedTranslatorSaga.react((recorded: recorded, item: _item())).toList();
    expect(commands, isEmpty);
  });

  // @requires any listed calendar event, however many times it is processed
  // @ensures exactly one command per new calendar event, and it names the same meeting and calendar id
  test('exactly one command per new calendar event', () async {
    for (final id in ['meeting-1', 'meeting-2']) {
      final commands = await calendarCreatedTranslatorSaga.react((
        recorded: const RecordedCalendarEventsState(),
        item: _item(meetingId: id, calendarEventId: 'cal-$id'),
      )).toList();
      expect(commands, hasLength(1));
      expect(commands.single.meetingId, MeetingId(id));
      expect(commands.single.calendarEventId, CalendarEventId('cal-$id'));
    }
  });
}
