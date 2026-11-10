import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/send_reschedule_notice/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

void main() {
  // @requires a confirmed meeting whose reschedule is completed, with the slice running alone
  // @ensures scenario completed_reschedule_is_announced: one email to both participants, one reschedule_notice_sent, and the item is not ready
  test('a completed reschedule sends one email to both participants', () async {
    final t = TestApp(slices: const [SendRescheduleNoticeSlice()]);
    await t.start();

    final reserved = reservedEvent();
    await t.given([reserved, confirmedEvent(), rescheduleRequested(), rescheduled()]);
    await t.drain();
    expect(t.mailer.sent, hasLength(1));
    expect(t.mailer.sent.single.to, ['alice@example.com', 'bob@example.com']);
    expect(t.mailer.sent.single.subject, 'Meeting rescheduled: Intro call');
    expect(t.mailer.sent.single.text, contains('Start: 2027-03-15T10:00:00.000Z'));
    expect(t.mailer.sent.single.text, contains('End: 2027-03-15T10:30:00.000Z'));
    expect(t.events.all.where((e) => e.event is RescheduleNoticeSentEvent), hasLength(1));
    final item = await t.views.get('reschedule_notices_to_send', reserved.meetingId.value);
    expect(item, isNotNull);
    expect(item!['ready'], isFalse);
  });

  // @requires a confirmed meeting that was moved directly in the calendar
  // @ensures scenario direct_move_is_announced: one email to both participants with the moved time
  test('a direct move sends one email with the moved time', () async {
    final t = TestApp(slices: const [SendRescheduleNoticeSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), movedInCalendar()]);
    await t.drain();
    expect(t.mailer.sent, hasLength(1));
    expect(t.mailer.sent.single.to, ['alice@example.com', 'bob@example.com']);
    expect(t.mailer.sent.single.text, contains('Start: 2027-03-15T11:00:00.000Z'));
    expect(t.events.all.where((e) => e.event is RescheduleNoticeSentEvent), hasLength(1));
  });

  // @requires a reschedule that is requested but not completed
  // @ensures scenario completed_reschedule_waits_for_announcement: nothing is sent until meeting_rescheduled arrives
  test('a reschedule that is not completed sends nothing', () async {
    final t = TestApp(slices: const [SendRescheduleNoticeSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), rescheduleRequested()]);
    await t.drain();
    expect(t.mailer.sent, isEmpty);
    expect(t.events.all.where((e) => e.event is RescheduleNoticeSentEvent), isEmpty);
  });

  // @requires a completed reschedule whose notice was sent, and its meeting_rescheduled event delivered again
  // @ensures the same new time is not announced twice: no second email and no second reschedule_notice_sent
  test('a repeated completion for the same new time sends nothing more', () async {
    final t = TestApp(slices: const [SendRescheduleNoticeSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), rescheduleRequested(), rescheduled()]);
    await t.drain();
    await t.given([rescheduled()]);
    await t.drain();
    expect(t.mailer.sent, hasLength(1));
    expect(t.events.all.where((e) => e.event is RescheduleNoticeSentEvent), hasLength(1));
  });

  // @requires a notice that was sent for one new time, then a later reschedule to another new time
  // @ensures the later reschedule is announced with its own email
  test('a later reschedule to another time is announced again', () async {
    final t = TestApp(slices: const [SendRescheduleNoticeSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), rescheduleRequested(), rescheduled()]);
    await t.drain();
    await t.given([
      rescheduleRequested(start: DateTime.utc(2027, 3, 15, 12), end: DateTime.utc(2027, 3, 15, 12, 30)),
      rescheduled(),
    ]);
    await t.drain();
    expect(t.mailer.sent, hasLength(2));
    expect(t.mailer.sent.last.text, contains('Start: 2027-03-15T12:00:00.000Z'));
  });
}
