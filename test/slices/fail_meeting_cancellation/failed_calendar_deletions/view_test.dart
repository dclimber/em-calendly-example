import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_meeting_cancellation/failed_calendar_deletions/state.dart';
import 'package:em_calendly_example/slices/fail_meeting_cancellation/failed_calendar_deletions/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  // @requires a calendar_event_deletion_failed answer, whose failure code is the reason
  // @ensures scenario deletion_failure_is_listed: the answer lists its meeting with its failure code
  test('deletion_failure_is_listed', () {
    final v = failedCalendarDeletionsView;
    expect(
      v.evolve(v.initialState, deletionFailedAnswer(meetingId: 'meeting-1', code: 'calendar_refused')),
      FailedCalendarDeletionState(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('calendar_refused')),
    );
  });

  // @requires any event that is not a failed deletion
  // @ensures the view yields no document for it
  test('other events list nothing', () {
    final v = failedCalendarDeletionsView;
    expect(v.evolve(v.initialState, cancellationRequestedEvent()), isNull);
    expect(v.evolve(v.initialState, reservedEvent()), isNull);
  });
}
