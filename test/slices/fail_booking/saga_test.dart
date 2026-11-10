import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_booking/failed_calendar_events/state.dart';
import 'package:em_calendly_example/slices/fail_booking/saga.dart';
import 'package:test/test.dart';

void main() {
  // @requires a listed negative answer for a meeting, with its reason
  // @ensures scenario translator_fails_the_booking: the processor emits one fail_booking command for the same meeting and reason
  test('translator_fails_the_booking', () async {
    final item = FailedCalendarEventState(
      meetingId: MeetingId('meeting-1'),
      failureReason: FailureReason('busy'),
    );
    final commands = await calendarFailureTranslatorSaga.react(item).toList();
    expect(commands.single.meetingId, MeetingId('meeting-1'));
    expect(commands.single.failureReason, FailureReason('busy'));
  });

  // @requires any listed negative answer, however many times it is processed
  // @ensures the processor emits exactly one command, and it names the same meeting and reason
  test('exactly one command per listed answer', () async {
    for (final id in ['meeting-1', 'meeting-2']) {
      final item = FailedCalendarEventState(
        meetingId: MeetingId(id),
        failureReason: FailureReason('reason-$id'),
      );
      final commands = await calendarFailureTranslatorSaga.react(item).toList();
      expect(commands, hasLength(1));
      expect(commands.single.meetingId, MeetingId(id));
      expect(commands.single.failureReason, FailureReason('reason-$id'));
    }
  });
}
