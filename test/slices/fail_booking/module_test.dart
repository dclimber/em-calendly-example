import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_booking/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

List<MeetingBookingFailedEvent> _failures(TestApp t) =>
    t.events.all.map((e) => e.event).whereType<MeetingBookingFailedEvent>().toList();

void main() {
  // @requires a meeting reserved and still pending_calendar, and a busy answer for it
  // @ensures scenario calendar_refuses_the_booking: the answer records exactly one booking_failed with the busy reason
  test('calendar_refuses_the_booking', () async {
    final t = TestApp(slices: const [FailBookingSlice()]);
    await t.start();

    await t.given([reservedEvent(), busyAnswer()]);
    await t.drain();
    final failures = _failures(t);
    expect(failures, hasLength(1));
    expect(failures.single.meetingId, MeetingId('meeting-1'));
    expect(
      failures.single.failureReason,
      FailureReason('This time is no longer available. Please choose another slot.'),
    );
  });

  // @requires an availability check failure, and a refused calendar change, each for a pending meeting
  // @ensures each records one booking_failed with its reason
  test('availability and creation failures record their reasons', () async {
    final t = TestApp(slices: const [FailBookingSlice()]);
    await t.start();

    await t.given([reservedEvent(meetingId: 'meeting-1'), availabilityFailedAnswer(meetingId: 'meeting-1')]);
    await t.drain();
    await t.given([
      reservedEvent(meetingId: 'meeting-2'),
      creationFailedAnswer(meetingId: 'meeting-2', code: 'refused'),
    ]);
    await t.drain();
    final failures = _failures(t);
    expect(failures, hasLength(2));
    expect(
      failures[0].failureReason,
      FailureReason("The host's availability cannot be verified right now. Please try again later."),
    );
    expect(failures[1].failureReason, FailureReason('refused'));
  });

  // @requires the same negative answer delivered again after the booking failed
  // @ensures the redelivery adds nothing: still one booking_failed
  test('a redelivered answer adds nothing', () async {
    final t = TestApp(slices: const [FailBookingSlice()]);
    await t.start();

    await t.given([reservedEvent(), busyAnswer()]);
    await t.drain();
    await t.given([busyAnswer()]);
    await t.drain();
    expect(_failures(t), hasLength(1));
  });

  // @requires a meeting already confirmed, and a negative answer for it
  // @ensures the answer records nothing, since the meeting is no longer pending_calendar
  test('a negative answer for a confirmed meeting records nothing', () async {
    final t = TestApp(slices: const [FailBookingSlice()]);
    await t.start();

    final reserved = reservedEvent();
    await t.given([
      reserved,
      MeetingConfirmedEvent(meetingId: reserved.meetingId, calendarEventId: CalendarEventId('cal-1')),
      busyAnswer(),
    ]);
    await t.drain();
    expect(_failures(t), isEmpty);
  });
}
