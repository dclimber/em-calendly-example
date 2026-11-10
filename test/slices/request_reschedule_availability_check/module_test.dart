import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_reschedule_availability_check/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

void main() {
  // @requires a booked meeting that is confirmed, then a reschedule request for a new time
  // @ensures the reschedule requests exactly one live check for the new slot, and the item leaves the to-do list
  test('a requested new time requests one live check', () async {
    final t = TestApp(slices: const [RequestRescheduleAvailabilityCheckSlice()]);
    await t.start();

    final requested = rescheduleRequestedEvent();
    await t.given([reservedEvent(), confirmedEvent(), requested]);
    await t.drain();
    final checks = t.events.all.where((e) => e.event is RescheduleAvailabilityCheckRequestedEvent).toList();
    expect(checks, hasLength(1));
    expect(checks.single.event, checkRequestedFor(requested));
    expect(await t.views.get('reschedules_awaiting_live_check', requested.meetingId.value), isNull);
  });

  // @requires a reschedule whose live check was already requested, and the same request delivered again
  // @ensures the repeated request requests nothing more: still one reschedule_availability_check_requested
  test('a repeated reschedule request requests nothing more', () async {
    final t = TestApp(slices: const [RequestRescheduleAvailabilityCheckSlice()]);
    await t.start();

    final requested = rescheduleRequestedEvent();
    await t.given([reservedEvent(), confirmedEvent(), requested]);
    await t.drain();
    await t.given([requested]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is RescheduleAvailabilityCheckRequestedEvent), hasLength(1));
  });

  // @requires a reschedule request, and a direct move of the meeting in the calendar before its check is requested
  // @ensures the direct move stops the check: no reschedule_availability_check_requested is appended
  test('a direct move stops the check', () async {
    final t = TestApp(slices: const [RequestRescheduleAvailabilityCheckSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), rescheduleRequestedEvent(), movedInCalendarEvent()]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is RescheduleAvailabilityCheckRequestedEvent), isEmpty);
  });
}
