import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_calendar_event_deletion/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

void main() {
  // @requires a confirmed meeting whose cancellation is requested, and the slice running alone
  // @ensures the requested cancellation requests exactly one calendar event deletion, and the item leaves the list
  test('a requested cancellation requests one calendar event deletion', () async {
    final t = TestApp(slices: const [RequestCalendarEventDeletionSlice()]);
    await t.start();

    final requested = cancellationRequestedEvent();
    await t.given([reservedEvent(), confirmedEvent(), requested]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is CalendarEventDeletionRequestedEvent), hasLength(1));
    expect(await t.views.get('cancellations_awaiting_calendar_deletion', requested.meetingId.value), isNull);
  });

  // @requires a requested cancellation whose deletion was already requested, and the same events delivered again
  // @ensures the redelivery requests nothing more: still one calendar_event_deletion_requested
  test('a second drain requests nothing more', () async {
    final t = TestApp(slices: const [RequestCalendarEventDeletionSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), cancellationRequestedEvent()]);
    await t.drain();
    await t.drain();
    expect(t.events.all.where((e) => e.event is CalendarEventDeletionRequestedEvent), hasLength(1));
  });

  // @requires a requested cancellation of a meeting that is canceled directly
  // @ensures the direct deletion stops the request: no calendar_event_deletion_requested is appended
  test('a direct deletion requests nothing', () async {
    final t = TestApp(slices: const [RequestCalendarEventDeletionSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), cancellationRequestedEvent(), canceledEvent()]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is CalendarEventDeletionRequestedEvent), isEmpty);
  });
}
