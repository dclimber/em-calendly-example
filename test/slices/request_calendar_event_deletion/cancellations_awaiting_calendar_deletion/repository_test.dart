import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/platform/view_store/in_memory_view_state_store.dart';
import 'package:em_calendly_example/slices/request_calendar_event_deletion/cancellations_awaiting_calendar_deletion/repository.dart';
import 'package:em_calendly_example/slices/request_calendar_event_deletion/cancellations_awaiting_calendar_deletion/state.dart';
import 'package:test/test.dart';

void main() {
  final repository = CancellationsAwaitingCalendarDeletionRepository(InMemoryViewStateStore());

  // @requires any open item of the to-do list
  // @ensures the document codec is lossless: decoding an encoded state gives back an equal state
  test('the document codec round-trips every state', () {
    final state = CancellationAwaitingCalendarDeletionState(
      meetingId: MeetingId('meeting-1'),
      calendarEventId: CalendarEventId('evt-1'),
    );
    expect(repository.decodeState(repository.encodeState(state)), state);
  });
}
