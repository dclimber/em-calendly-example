import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_calendar_event_deletion/cancellations_awaiting_calendar_deletion/state.dart';
import 'package:em_calendly_example/slices/request_calendar_event_deletion/request_calendar_event_deletion/command.dart';
import 'package:em_calendly_example/slices/request_calendar_event_deletion/saga.dart';
import 'package:test/test.dart';

CancellationAwaitingCalendarDeletionState _item({String meetingId = 'meeting-1'}) =>
    CancellationAwaitingCalendarDeletionState(
      meetingId: MeetingId(meetingId),
      calendarEventId: CalendarEventId('evt-1'),
    );

void main() {
  // @requires an open item of cancellations_awaiting_calendar_deletion
  // @ensures scenario cancellation_requests_calendar_deletion: the processor emits one request_calendar_event_deletion
  // command for its meeting
  test('cancellation_requests_calendar_deletion', () async {
    final commands = await calendarDeletionRequesterSaga.react(_item()).toList();
    expect(commands, [RequestCalendarEventDeletionCommand(meetingId: MeetingId('meeting-1'))]);
  });

  // @requires any open item, however many times it is processed
  // @ensures the processor emits exactly one command per item, and it names the same meeting
  test('exactly one command per open item', () async {
    for (final id in ['meeting-1', 'meeting-2']) {
      final commands = await calendarDeletionRequesterSaga.react(_item(meetingId: id)).toList();
      expect(commands, hasLength(1));
      expect(commands.single.meetingId, MeetingId(id));
    }
  });
}
