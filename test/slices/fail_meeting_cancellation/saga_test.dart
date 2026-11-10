import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_meeting_cancellation/failed_calendar_deletions/state.dart';
import 'package:em_calendly_example/slices/fail_meeting_cancellation/saga.dart';
import 'package:test/test.dart';

void main() {
  // @requires a listed failed deletion for a meeting, with its reason
  // @ensures scenario deletion_failure_keeps_the_meeting: the processor emits one fail_cancellation command for the same
  // meeting and reason
  test('deletion_failure_keeps_the_meeting', () async {
    final item = FailedCalendarDeletionState(
      meetingId: MeetingId('meeting-1'),
      failureReason: FailureReason('refused'),
    );
    final commands = await calendarDeletionFailureTranslatorSaga.react(item).toList();
    expect(commands.single.meetingId, MeetingId('meeting-1'));
    expect(commands.single.failureReason, FailureReason('refused'));
  });

  // @requires any listed failed deletion, however many times it is processed
  // @ensures the processor emits exactly one command, and it names the same meeting and reason
  test('exactly one command per listed deletion', () async {
    for (final id in ['meeting-1', 'meeting-2']) {
      final item = FailedCalendarDeletionState(meetingId: MeetingId(id), failureReason: FailureReason('reason-$id'));
      final commands = await calendarDeletionFailureTranslatorSaga.react(item).toList();
      expect(commands, hasLength(1));
      expect(commands.single.meetingId, MeetingId(id));
      expect(commands.single.failureReason, FailureReason('reason-$id'));
    }
  });
}
