import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_deletion/direct_calendar_deletions/state.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_deletion/direct_calendar_deletions/view.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  // @requires a calendar_event_deleted_directly event
  // @ensures scenario direct_deletion_is_listed: the meeting appears
  test('direct_deletion_is_listed', () {
    final state = directCalendarDeletionsView.evolve(directCalendarDeletionsView.initialState, deletedDirectly());
    expect(state, DirectCalendarDeletionState(meetingId: MeetingId('meeting-1')));
  });

  // @requires any event that is not a direct deletion
  // @ensures the view lists nothing for it
  test('other events list nothing', () {
    expect(directCalendarDeletionsView.evolve(directCalendarDeletionsView.initialState, confirmedEvent()), isNull);
  });
}
