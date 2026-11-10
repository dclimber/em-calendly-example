import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_move/direct_calendar_moves/state.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_move/direct_calendar_moves/view.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  // @requires a calendar_event_moved_directly event
  // @ensures scenario direct_move_is_listed: the meeting appears with its moved times
  test('direct_move_is_listed', () {
    final state = directCalendarMovesView.evolve(directCalendarMovesView.initialState, movedDirectly());
    expect(
      state,
      DirectCalendarMoveState(
        meetingId: MeetingId('meeting-1'),
        newSlotStart: NewSlotStart(DateTime.utc(2027, 3, 16, 14)),
        newSlotEnd: NewSlotEnd(DateTime.utc(2027, 3, 16, 14, 30)),
      ),
    );
  });

  // @requires any event that is not a direct move
  // @ensures the view lists nothing for it
  test('other events list nothing', () {
    expect(directCalendarMovesView.evolve(directCalendarMovesView.initialState, confirmedEvent()), isNull);
  });
}
