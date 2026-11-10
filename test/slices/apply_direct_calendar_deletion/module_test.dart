import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_deletion/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

List<MeetingCanceledEvent> _canceled(TestApp t) =>
    t.events.all.map((e) => e.event).whereType<MeetingCanceledEvent>().toList();

void main() {
  // @requires a confirmed meeting whose calendar event was deleted directly
  // @ensures exactly one meeting_canceled for the meeting
  test('a confirmed meeting that is deleted in the calendar gets exactly one meeting_canceled', () async {
    final t = TestApp(slices: const [ApplyDirectCalendarDeletionSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), deletedDirectly()]);
    await t.drain();
    expect(_canceled(t), [canceledEvent()]);
  });

  // @requires a meeting in rescheduling whose calendar event was deleted directly
  // @ensures the calendar wins: one meeting_canceled ends the reschedule
  test('a direct deletion ends a reschedule in progress', () async {
    final t = TestApp(slices: const [ApplyDirectCalendarDeletionSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), rescheduleRequestedEvent(), deletedDirectly()]);
    await t.drain();
    expect(_canceled(t), [canceledEvent()]);
  });

  // @requires a completed meeting whose calendar event was deleted directly
  // @ensures no meeting_canceled is recorded and the subscription does not fail
  test('a completed meeting gets no meeting_canceled', () async {
    final t = TestApp(slices: const [ApplyDirectCalendarDeletionSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), completedEvent(), deletedDirectly()]);
    await t.drain();
    expect(_canceled(t), isEmpty);
  });
}
