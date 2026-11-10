import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/send_cancellation_notice/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

void main() {
  // @requires a confirmed meeting that the scheduler canceled, with the slice running alone
  // @ensures scenario canceled_meeting_is_announced: one email to both participants, one cancellation_notice_sent, and the item is not ready
  test('a canceled meeting sends one email to both participants and one notice event', () async {
    final t = TestApp(slices: const [SendCancellationNoticeSlice()]);
    await t.start();

    final reserved = reservedEvent();
    await t.given([reserved, confirmedEvent(), cancellationRequested(), canceled()]);
    await t.drain();
    expect(t.mailer.sent, hasLength(1));
    expect(t.mailer.sent.single.to, ['alice@example.com', 'bob@example.com']);
    expect(t.mailer.sent.single.subject, 'Meeting canceled: Intro call');
    expect(t.mailer.sent.single.text, contains('Start: 2027-03-15T09:00:00.000Z'));
    expect(t.mailer.sent.single.text, contains('Intro call'));
    expect(t.events.all.where((e) => e.event is CancellationNoticeSentEvent), hasLength(1));
    final item = await t.views.get('cancellation_notices_to_send', reserved.meetingId.value);
    expect(item, isNotNull);
    expect(item!['ready'], isFalse);
  });

  // @requires a second drain after the notice was sent
  // @ensures a second drain adds nothing: no second email and no second cancellation_notice_sent
  test('a second drain after the notice adds nothing', () async {
    final t = TestApp(slices: const [SendCancellationNoticeSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), cancellationRequested(), canceled()]);
    await t.drain();
    await t.drain();
    expect(t.mailer.sent, hasLength(1));
    expect(t.events.all.where((e) => e.event is CancellationNoticeSentEvent), hasLength(1));
  });

  // @requires a redelivered meeting_canceled after the notice was sent
  // @ensures the repeat sends neither a second email nor a second event
  test('a redelivered meeting_canceled sends nothing more', () async {
    final t = TestApp(slices: const [SendCancellationNoticeSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), canceled()]);
    await t.drain();
    await t.given([canceled()]);
    await t.drain();
    expect(t.mailer.sent, hasLength(1));
    expect(t.events.all.where((e) => e.event is CancellationNoticeSentEvent), hasLength(1));
  });

  // @requires a direct deletion in the calendar: no cancellation_requested event
  // @ensures scenario direct_deletion_is_announced: one email to both participants and one notice event
  test('a direct deletion sends one email to both participants', () async {
    final t = TestApp(slices: const [SendCancellationNoticeSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), canceled()]);
    await t.drain();
    expect(t.mailer.sent, hasLength(1));
    expect(t.mailer.sent.single.to, ['alice@example.com', 'bob@example.com']);
    expect(t.events.all.where((e) => e.event is CancellationNoticeSentEvent), hasLength(1));
  });

  // @requires a cancellation that is requested but not completed
  // @ensures scenario canceled_meeting_waits_for_announcement: nothing is sent until meeting_canceled arrives
  test('a cancellation that is not completed sends nothing', () async {
    final t = TestApp(slices: const [SendCancellationNoticeSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), cancellationRequested()]);
    await t.drain();
    expect(t.mailer.sent, isEmpty);
    expect(t.events.all.where((e) => e.event is CancellationNoticeSentEvent), isEmpty);
  });
}
