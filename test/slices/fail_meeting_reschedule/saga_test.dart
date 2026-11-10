import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_meeting_reschedule/failed_calendar_updates/state.dart';
import 'package:em_calendly_example/slices/fail_meeting_reschedule/saga.dart';
import 'package:test/test.dart';

void main() {
  // @requires a listed negative answer for a meeting, with its reason
  // @ensures scenario update_failure_keeps_the_original_time: the processor emits one fail_reschedule command for the same
  // meeting and reason
  test('update_failure_keeps_the_original_time', () async {
    final item = FailedCalendarUpdateState(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('refused'));
    final commands = await calendarUpdateFailureTranslatorSaga.react(item).toList();
    expect(commands.single.meetingId, MeetingId('meeting-1'));
    expect(commands.single.failureReason, FailureReason('refused'));
  });

  // @requires a busy answer or an unanswered check for a meeting, with its reason
  // @ensures scenarios busy_host_keeps_the_original_time and unanswered_check_keeps_the_original_time: one command each
  test('busy_host_keeps_the_original_time and unanswered_check_keeps_the_original_time', () async {
    for (final reason in ['busy', 'unanswered']) {
      final item = FailedCalendarUpdateState(meetingId: MeetingId('meeting-2'), failureReason: FailureReason(reason));
      final commands = await calendarUpdateFailureTranslatorSaga.react(item).toList();
      expect(commands, hasLength(1));
      expect(commands.single.meetingId, MeetingId('meeting-2'));
      expect(commands.single.failureReason, FailureReason(reason));
    }
  });

  // @requires any listed negative answer, however many times it is processed
  // @ensures the processor emits exactly one command, and it names the same meeting and reason
  test('exactly one command per listed answer', () async {
    for (final id in ['meeting-1', 'meeting-2']) {
      final item = FailedCalendarUpdateState(meetingId: MeetingId(id), failureReason: FailureReason('reason-$id'));
      final commands = await calendarUpdateFailureTranslatorSaga.react(item).toList();
      expect(commands, hasLength(1));
      expect(commands.single.meetingId, MeetingId(id));
      expect(commands.single.failureReason, FailureReason('reason-$id'));
    }
  });
}
