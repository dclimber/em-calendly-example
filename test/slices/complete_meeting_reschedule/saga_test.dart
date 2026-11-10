import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/complete_meeting_reschedule/complete_reschedule/command.dart';
import 'package:em_calendly_example/slices/complete_meeting_reschedule/saga.dart';
import 'package:em_calendly_example/slices/complete_meeting_reschedule/updated_calendar_events/state.dart';
import 'package:em_calendly_example/slices/complete_meeting_reschedule/updated_calendar_events/view.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  // @requires a calendar event that the calendar system moved for a meeting
  // @ensures scenario moved_event_is_listed: the view lists the meeting as an updated calendar event
  test('moved_event_is_listed', () {
    final item = updatedCalendarEventsView.evolve(updatedCalendarEventsView.initialState, calendarEventUpdated());
    expect(item, UpdatedCalendarEventState(meetingId: MeetingId('meeting-1')));
  });

  // @requires any event that is not calendar_event_updated
  // @ensures the view lists nothing
  test('other events list nothing', () {
    final item = updatedCalendarEventsView.evolve(updatedCalendarEventsView.initialState, rescheduledEvent());
    expect(item, isNull);
  });

  // @requires a listed updated calendar event
  // @ensures scenario moved_event_completes_the_reschedule: the processor emits one complete_reschedule command
  test('moved_event_completes_the_reschedule', () async {
    final item = UpdatedCalendarEventState(meetingId: MeetingId('meeting-1'));
    final commands = await calendarUpdatedTranslatorSaga.react(item).toList();
    expect(commands, [CompleteRescheduleCommand(meetingId: MeetingId('meeting-1'))]);
  });

  // @requires any listed updated calendar event
  // @ensures exactly one command per event, naming the same meeting
  test('exactly one command per updated calendar event', () async {
    for (final id in ['meeting-1', 'meeting-2']) {
      final commands = await calendarUpdatedTranslatorSaga
          .react(
            UpdatedCalendarEventState(meetingId: MeetingId(id)),
          )
          .toList();
      expect(commands, [CompleteRescheduleCommand(meetingId: MeetingId(id))]);
    }
  });
}
