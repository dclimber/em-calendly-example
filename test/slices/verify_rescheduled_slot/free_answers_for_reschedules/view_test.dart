import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/verify_rescheduled_slot/free_answers_for_reschedules/state.dart';
import 'package:em_calendly_example/slices/verify_rescheduled_slot/free_answers_for_reschedules/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  // @requires a host_slot_found_free answer for a meeting
  // @ensures scenario free_answer_is_listed: the answer lists its meeting, named by the scheduler meeting ref
  test('free_answer_is_listed', () {
    final v = freeAnswersForReschedulesView;
    expect(
      v.evolve(v.initialState, freeAnswer(meetingId: 'meeting-1')),
      FreeAnswerForRescheduleState(meetingId: MeetingId('meeting-1')),
    );
  });

  // @requires a reschedule_availability_check_requested event, which opens no item
  // @ensures the request yields no item, with or without an earlier answer
  test('a request opens no item', () {
    final v = freeAnswersForReschedulesView;
    final requested = checkRequestedFor(rescheduleRequestedEvent());
    expect(v.evolve(v.initialState, requested), isNull);
    final listed = v.evolve(v.initialState, freeAnswer());
    expect(v.evolve(listed, requested), isNull);
  });

  // @requires a meeting_slot_reserved event, which is not an answer of the check
  // @ensures the reservation lists nothing
  test('a reservation lists nothing', () {
    final v = freeAnswersForReschedulesView;
    expect(v.evolve(v.initialState, reservedEvent()), isNull);
  });
}
