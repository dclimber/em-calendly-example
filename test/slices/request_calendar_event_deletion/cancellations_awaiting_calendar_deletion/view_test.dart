import 'package:em_calendly_example/slices/request_calendar_event_deletion/cancellations_awaiting_calendar_deletion/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  final v = cancellationsAwaitingCalendarDeletionView;
  final requested = cancellationRequestedEvent();

  // @requires a meeting_cancellation_requested event
  // @ensures scenario cancellation_waits_for_deletion: the item is listed with its meeting and calendar event
  test('cancellation_waits_for_deletion', () {
    final state = v.evolve(v.initialState, requested);
    expect(state, isNotNull);
    expect(state!.meetingId, requested.meetingId);
    expect(state.calendarEventId, requested.calendarEventId);
  });

  // @requires a requested cancellation followed by its calendar_event_deletion_requested event
  // @ensures scenario requested_deletion_leaves_the_list: the item leaves the list (the state is null)
  test('requested_deletion_leaves_the_list', () {
    expect(v.evolve(v.evolve(v.initialState, requested), deletionRequestedEvent()), isNull);
  });

  // @requires a requested cancellation followed by the direct deletion of the meeting (meeting_canceled)
  // @ensures scenario direct_deletion_stops_the_request: the item leaves the list (the state is null)
  test('direct_deletion_stops_the_request', () {
    expect(v.evolve(v.evolve(v.initialState, requested), canceledEvent()), isNull);
  });

  // @requires a meeting_cancellation_failed event after a requested cancellation
  // @ensures the failure leaves the item unchanged: it still waits for its deletion
  test('a failed cancellation keeps the item unchanged', () {
    final open = v.evolve(v.initialState, requested);
    expect(v.evolve(open, cancellationFailedEvent()), equals(open));
  });

  // @requires a calendar_event_deletion_requested event or a meeting_canceled event with no open item
  // @ensures the closing event opens no item: the state stays null
  test('a closing event without an item opens no item', () {
    expect(v.evolve(v.initialState, deletionRequestedEvent()), isNull);
    expect(v.evolve(v.initialState, canceledEvent()), isNull);
  });

  // @requires any requested cancellation, folded twice, and then the closing event folded twice
  // @ensures folding a repeated event yields the same result (idempotent)
  test('repeated events yield the same result', () {
    final once = v.evolve(v.initialState, requested);
    expect(v.evolve(once, requested), equals(once));
    final closed = v.evolve(once, deletionRequestedEvent());
    expect(v.evolve(closed, deletionRequestedEvent()), isNull);
    expect(v.evolve(v.evolve(once, canceledEvent()), canceledEvent()), isNull);
  });
}
