import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/complete_finished_meeting/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

Iterable<Object> _completions(TestApp t) => t.events.all.map((e) => e.event).whereType<MeetingCompletedEvent>();

void main() {
  // @requires a confirmed meeting whose end is still ahead of the clock
  // @ensures the job completes nothing before the end
  test('a meeting is not completed before its end', () async {
    final t = TestApp(slices: const [CompleteFinishedMeetingSlice()]);
    await t.start();
    await t.given([reservedEvent(), confirmedEvent()]);
    await t.drain();

    await t.runJobs();
    expect(_completions(t), isEmpty);
  });

  // @requires a confirmed meeting whose end has passed on the clock
  // @ensures the job appends exactly one meeting_completed, and a second run appends nothing more
  test('the job completes an ended meeting once', () async {
    final t = TestApp(slices: const [CompleteFinishedMeetingSlice()]);
    await t.start();
    await t.given([reservedEvent(), confirmedEvent()]);
    await t.drain();

    t.clock.set(meetingEnd);
    await t.runJobs();
    await t.drain();
    await t.runJobs();
    expect(_completions(t), hasLength(1));
  });

  // @requires a confirmed meeting that is moved directly in the calendar to a later end
  // @ensures the job waits for the new end: nothing is completed at the old end, and the meeting completes at the new one
  test('a directly moved meeting waits for its new end', () async {
    final t = TestApp(slices: const [CompleteFinishedMeetingSlice()]);
    await t.start();
    final newEnd = meetingEnd.add(const Duration(hours: 1));
    await t.given([reservedEvent(), confirmedEvent(), movedInCalendarEvent(newSlotEnd: newEnd)]);
    await t.drain();

    t.clock.set(meetingEnd);
    await t.runJobs();
    expect(_completions(t), isEmpty);

    t.clock.set(newEnd);
    await t.runJobs();
    expect(_completions(t), hasLength(1));
  });

  // @requires a confirmed meeting whose reschedule to a later end is requested, then fails
  // @ensures the job completes the meeting at its original end, not at the failed request's end
  test('a meeting whose reschedule failed is completed at its original end', () async {
    final t = TestApp(slices: const [CompleteFinishedMeetingSlice()]);
    await t.start();
    final requestedEnd = meetingEnd.add(const Duration(hours: 1));
    await t.given([
      reservedEvent(),
      confirmedEvent(),
      rescheduleRequestedEvent(newSlotEnd: requestedEnd),
      rescheduleFailedEvent(),
    ]);
    await t.drain();

    t.clock.set(meetingEnd);
    await t.runJobs();
    expect(_completions(t), hasLength(1));
  });

  // @requires a canceled meeting whose end has passed
  // @ensures the job completes nothing: the item left the list at cancellation
  test('a canceled meeting is not completed', () async {
    final t = TestApp(slices: const [CompleteFinishedMeetingSlice()]);
    await t.start();
    await t.given([reservedEvent(), confirmedEvent(), canceledEvent()]);
    await t.drain();

    t.clock.set(meetingEnd);
    await t.runJobs();
    expect(_completions(t), isEmpty);
  });
}
