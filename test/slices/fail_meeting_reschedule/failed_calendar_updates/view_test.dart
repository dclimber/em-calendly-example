import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_meeting_reschedule/failed_calendar_updates/state.dart';
import 'package:em_calendly_example/slices/fail_meeting_reschedule/failed_calendar_updates/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  // @requires a calendar_event_update_failed answer, whose failure code is the reason
  // @ensures scenario update_failure_is_listed: the answer lists its meeting with its failure code
  test('update_failure_is_listed', () {
    final v = failedCalendarUpdatesView;
    expect(
      v.evolve(v.initialState, updateFailedAnswer(meetingId: 'meeting-1', code: 'calendar_refused')),
      FailedCalendarUpdateState(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('calendar_refused')),
    );
  });

  // @requires a host_slot_found_busy answer for a meeting
  // @ensures scenario busy_host_keeps_the_original_time: the answer lists its meeting with the busy reason text
  test('busy_answer_lists_the_reschedule', () {
    final v = failedCalendarUpdatesView;
    expect(
      v.evolve(v.initialState, busyAnswer(meetingId: 'meeting-1')),
      FailedCalendarUpdateState(
        meetingId: MeetingId('meeting-1'),
        failureReason: FailureReason('This time is no longer available. Please choose another slot.'),
      ),
    );
  });

  // @requires an availability_check_failed answer, whose failure code is not the reason
  // @ensures scenario unanswered_check_keeps_the_original_time: the answer lists its meeting with the fixed text
  test('availability_failure_lists_the_reschedule_with_fixed_text', () {
    final v = failedCalendarUpdatesView;
    expect(
      v.evolve(v.initialState, availabilityFailedAnswer(meetingId: 'meeting-1')),
      FailedCalendarUpdateState(
        meetingId: MeetingId('meeting-1'),
        failureReason: FailureReason(
          "The host's availability cannot be verified right now. Please try again later.",
        ),
      ),
    );
  });

  // @requires a reschedule_availability_check_requested event, which opens no item
  // @ensures it lists nothing
  test('a requested check lists nothing', () {
    final v = failedCalendarUpdatesView;
    expect(v.evolve(v.initialState, rescheduleCheckRequestedEvent()), isNull);
  });
}
