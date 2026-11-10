import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/complete_meeting_cancellation/complete_cancellation/command.dart';
import 'package:em_calendly_example/slices/complete_meeting_cancellation/deleted_calendar_events/state.dart';
import 'package:em_calendly_example/slices/complete_meeting_cancellation/deleted_calendar_events/view.dart';
import 'package:em_calendly_example/slices/complete_meeting_cancellation/saga.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  // @requires a calendar event that the calendar system deleted for a meeting
  // @ensures scenario deleted_event_is_listed: the view lists the meeting as a deleted calendar event
  test('deleted_event_is_listed', () {
    final item = deletedCalendarEventsView.evolve(deletedCalendarEventsView.initialState, calendarEventDeleted());
    expect(item, DeletedCalendarEventState(meetingId: MeetingId('meeting-1')));
  });

  // @requires any event that is not calendar_event_deleted
  // @ensures the view lists nothing
  test('other events list nothing', () {
    final item = deletedCalendarEventsView.evolve(deletedCalendarEventsView.initialState, canceledEvent());
    expect(item, isNull);
  });

  // @requires a listed deleted calendar event
  // @ensures scenario deleted_event_cancels_the_meeting: the processor emits one complete_cancellation command
  test('deleted_event_cancels_the_meeting', () async {
    final item = DeletedCalendarEventState(meetingId: MeetingId('meeting-1'));
    final commands = await calendarDeletedTranslatorSaga.react(item).toList();
    expect(commands, [CompleteCancellationCommand(meetingId: MeetingId('meeting-1'))]);
  });

  // @requires any listed deleted calendar event
  // @ensures exactly one command per event, naming the same meeting
  test('exactly one command per deleted calendar event', () async {
    for (final id in ['meeting-1', 'meeting-2']) {
      final commands = await calendarDeletedTranslatorSaga
          .react(DeletedCalendarEventState(meetingId: MeetingId(id)))
          .toList();
      expect(commands, [CompleteCancellationCommand(meetingId: MeetingId(id))]);
    }
  });
}
