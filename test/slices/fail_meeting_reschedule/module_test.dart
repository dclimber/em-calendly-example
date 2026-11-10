import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_meeting_reschedule/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

List<MeetingRescheduleFailedEvent> _failures(TestApp t) =>
    t.events.all.map((e) => e.event).whereType<MeetingRescheduleFailedEvent>().toList();

List<MeetingBookingFailedEvent> _bookingFailures(TestApp t) =>
    t.events.all.map((e) => e.event).whereType<MeetingBookingFailedEvent>().toList();

/// Reserves and confirms a meeting, then moves it to rescheduling.
List<MeetingsEvent> _rescheduling({String meetingId = 'meeting-1'}) => [
  reservedEvent(meetingId: meetingId),
  confirmedEvent(meetingId: meetingId),
  rescheduleRequestedEvent(meetingId: meetingId),
];

void main() {
  // @requires a meeting rescheduling, and the live check finds the host's new slot busy
  // @ensures scenario busy_host_keeps_the_original_time: the answer records exactly one reschedule_failed with the busy
  // reason, and no booking_failed
  test('busy_host_keeps_the_original_time', () async {
    final t = TestApp(slices: const [FailMeetingRescheduleSlice()]);
    await t.start();

    await t.given([..._rescheduling(), busyAnswer()]);
    await t.drain();
    final failures = _failures(t);
    expect(failures, hasLength(1));
    expect(failures.single.meetingId, MeetingId('meeting-1'));
    expect(
      failures.single.failureReason,
      FailureReason('This time is no longer available. Please choose another slot.'),
    );
    expect(_bookingFailures(t), isEmpty);
  });

  // @requires a meeting rescheduling, and the live check could not be answered
  // @ensures scenario unanswered_check_keeps_the_original_time: exactly one reschedule_failed with the fixed availability
  // reason, and no booking_failed
  test('unanswered_check_keeps_the_original_time', () async {
    final t = TestApp(slices: const [FailMeetingRescheduleSlice()]);
    await t.start();

    await t.given([..._rescheduling(), availabilityFailedAnswer()]);
    await t.drain();
    final failures = _failures(t);
    expect(failures, hasLength(1));
    expect(
      failures.single.failureReason,
      FailureReason("The host's availability cannot be verified right now. Please try again later."),
    );
    expect(_bookingFailures(t), isEmpty);
  });

  // @requires a meeting rescheduling, and the calendar system refuses the change with a failure code
  // @ensures scenario update_failure_keeps_the_original_time: exactly one reschedule_failed that keeps the failure code,
  // and no booking_failed
  test('update_failure_keeps_the_original_time', () async {
    final t = TestApp(slices: const [FailMeetingRescheduleSlice()]);
    await t.start();

    await t.given([..._rescheduling(), updateFailedAnswer(code: 'calendar_refused')]);
    await t.drain();
    final failures = _failures(t);
    expect(failures, hasLength(1));
    expect(failures.single.failureReason, FailureReason('calendar_refused'));
    expect(_bookingFailures(t), isEmpty);
  });

  // @requires a negative answer delivered again after the reschedule failed
  // @ensures the redelivery adds nothing: still one reschedule_failed
  test('a redelivered answer adds nothing', () async {
    final t = TestApp(slices: const [FailMeetingRescheduleSlice()]);
    await t.start();

    await t.given([..._rescheduling(), busyAnswer()]);
    await t.drain();
    await t.given([busyAnswer()]);
    await t.drain();
    expect(_failures(t), hasLength(1));
  });

  // @requires a meeting that is confirmed and not rescheduling, and a negative answer for it
  // @ensures the answer records nothing
  test('a negative answer outside rescheduling records nothing', () async {
    final t = TestApp(slices: const [FailMeetingRescheduleSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), busyAnswer()]);
    await t.drain();
    expect(_failures(t), isEmpty);
    expect(_bookingFailures(t), isEmpty);
  });
}
