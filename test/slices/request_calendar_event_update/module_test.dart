import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_calendar_event_update/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

void main() {
  // @requires a confirmed meeting, then a reschedule request and its verified new slot
  // @ensures the verified reschedule requests exactly one calendar_event_update_requested, and the item leaves the list
  test('a verified reschedule requests one calendar event update', () async {
    final t = TestApp(slices: const [RequestCalendarEventUpdateSlice()]);
    await t.start();

    final requested = rescheduleRequestedEvent();
    await t.given([reservedEvent(), confirmedEvent(), requested, newSlotVerifiedEvent()]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is CalendarEventUpdateRequestedEvent), hasLength(1));
    expect(await t.views.get('reschedules_awaiting_calendar_update', requested.meetingId.value), isNull);
  });

  // @requires a reschedule request whose new slot is not verified yet
  // @ensures the slice requests nothing until the new_slot_verified event arrives
  test('an unverified reschedule requests nothing', () async {
    final t = TestApp(slices: const [RequestCalendarEventUpdateSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), rescheduleRequestedEvent()]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is CalendarEventUpdateRequestedEvent), isEmpty);
    expect(
      await t.views.get('reschedules_awaiting_calendar_update', 'meeting-1'),
      isNotNull,
    );
  });
}
