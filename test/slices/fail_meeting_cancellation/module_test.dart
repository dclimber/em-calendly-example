import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_meeting_cancellation/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

List<MeetingCancellationFailedEvent> _failures(TestApp t) =>
    t.events.all.map((e) => e.event).whereType<MeetingCancellationFailedEvent>().toList();

/// Reserves and confirms a meeting, then moves it to canceling.
List<MeetingsEvent> _canceling({String meetingId = 'meeting-1'}) => [
  reservedEvent(meetingId: meetingId),
  confirmedEvent(meetingId: meetingId),
  cancellationRequestedEvent(meetingId: meetingId),
];

void main() {
  // @requires a meeting canceling, and the calendar system could not remove the event
  // @ensures scenario deletion_failure_keeps_the_meeting: exactly one cancellation_failed with the mapped reason
  test('deletion_failure_keeps_the_meeting', () async {
    final t = TestApp(slices: const [FailMeetingCancellationSlice()]);
    await t.start();

    await t.given([..._canceling(), deletionFailedAnswer(code: 'calendar_refused')]);
    await t.drain();
    final failures = _failures(t);
    expect(failures, hasLength(1));
    expect(failures.single.meetingId, MeetingId('meeting-1'));
    expect(failures.single.failureReason, FailureReason('calendar_refused'));
  });

  // @requires a failed deletion delivered again after the cancellation failed
  // @ensures the redelivery adds nothing: still one cancellation_failed
  test('a redelivered answer adds nothing', () async {
    final t = TestApp(slices: const [FailMeetingCancellationSlice()]);
    await t.start();

    await t.given([..._canceling(), deletionFailedAnswer()]);
    await t.drain();
    await t.given([deletionFailedAnswer()]);
    await t.drain();
    expect(_failures(t), hasLength(1));
  });

  // @requires a meeting that is confirmed and not canceling, and a failed deletion for it
  // @ensures the answer records nothing
  test('a failed deletion outside canceling records nothing', () async {
    final t = TestApp(slices: const [FailMeetingCancellationSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), deletionFailedAnswer()]);
    await t.drain();
    expect(_failures(t), isEmpty);
  });
}
