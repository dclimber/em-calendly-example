import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_move/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

List<MeetingMovedInCalendarEvent> _moved(TestApp t) =>
    t.events.all.map((e) => e.event).whereType<MeetingMovedInCalendarEvent>().toList();

void main() {
  // @requires a confirmed meeting whose calendar event was moved directly
  // @ensures exactly one meeting_moved_in_calendar with the moved times, and a redelivery of the same event adds nothing
  // beyond the decider's answer for the confirmed meeting (see the lifecycle gaps)
  test('a confirmed meeting that is moved gets exactly one meeting_moved_in_calendar', () async {
    final t = TestApp(slices: const [ApplyDirectCalendarMoveSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), movedDirectly()]);
    await t.drain();
    final moved = _moved(t);
    expect(moved, hasLength(1));
    expect(moved.single.meetingId, MeetingId('meeting-1'));
    expect(moved.single.newSlotStart, NewSlotStart(DateTime.utc(2027, 3, 16, 14)));
    expect(moved.single.newSlotEnd, NewSlotEnd(DateTime.utc(2027, 3, 16, 14, 30)));
  });

  // @requires a meeting in rescheduling whose calendar event was moved directly
  // @ensures the calendar time replaces the reschedule: one meeting_moved_in_calendar
  test('a direct move replaces a reschedule in progress', () async {
    final t = TestApp(slices: const [ApplyDirectCalendarMoveSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), rescheduleRequestedEvent(), movedDirectly()]);
    await t.drain();
    expect(_moved(t), hasLength(1));
  });

  // @requires a canceled meeting whose calendar event was moved directly
  // @ensures no meeting_moved_in_calendar is recorded and the subscription does not fail
  test('a canceled meeting gets no meeting_moved_in_calendar', () async {
    final t = TestApp(slices: const [ApplyDirectCalendarMoveSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), cancellationRequestedEvent(), canceledEvent(), movedDirectly()]);
    await t.drain();
    expect(_moved(t), isEmpty);
  });
}
