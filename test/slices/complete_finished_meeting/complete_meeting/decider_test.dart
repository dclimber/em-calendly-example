import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/complete_finished_meeting/complete_meeting/command.dart';
import 'package:em_calendly_example/slices/complete_finished_meeting/complete_meeting/decider.dart';
import 'package:em_calendly_example/slices/complete_finished_meeting/complete_meeting/errors.dart';
import 'package:em_calendly_example/slices/complete_finished_meeting/complete_meeting/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

CompleteMeetingState _fold(List<MeetingsEvent> history) =>
    history.fold(completeMeetingDecider.initialState, completeMeetingDecider.evolve);

void main() {
  final command = CompleteMeetingCommand(meetingId: MeetingId('meeting-1'));
  final reserved = reservedEvent();
  final confirmed = confirmedEvent();

  // @requires a confirmed meeting whose end has passed
  // @ensures scenario happy_path: the decider emits one meeting_completed for the meeting
  test('happy_path', () async {
    final events = await completeMeetingDecider.decide(command, _fold([reserved, confirmed])).toList();
    expect(events, [completedEvent()]);
  });

  // @requires a meeting in each lifecycle state other than confirmed: none, pending_calendar, rescheduling, canceling,
  // canceled, completed, booking_failed
  // @ensures the decider refuses with MeetingNotConfirmedError and emits nothing
  test('a meeting outside confirmed is refused', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [reserved],
      [reserved, confirmed, rescheduleRequestedEvent(newSlotEnd: meetingEnd)],
      [reserved, confirmed, cancellationRequestedEvent()],
      [reserved, confirmed, canceledEvent()],
      [reserved, confirmed, completedEvent()],
      [reserved, bookingFailedEvent()],
    ];
    for (final history in histories) {
      await expectLater(
        completeMeetingDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<MeetingNotConfirmedError>()),
      );
    }
  });

  // @requires a meeting that was rescheduled, or whose reschedule or cancellation failed, and is confirmed again
  // @ensures the decider completes it: confirmed is the only accepted state
  test('a meeting back in confirmed is completed', () async {
    final histories = <List<MeetingsEvent>>[
      [reserved, confirmed, rescheduleRequestedEvent(newSlotEnd: meetingEnd), rescheduledEvent()],
      [reserved, confirmed, rescheduleRequestedEvent(newSlotEnd: meetingEnd), rescheduleFailedEvent()],
      [reserved, confirmed, cancellationRequestedEvent(), cancellationFailedEvent()],
    ];
    for (final history in histories) {
      expect(await completeMeetingDecider.decide(command, _fold(history)).toList(), [completedEvent()]);
    }
  });

  // @requires a confirmed meeting that is completed, and the decider folds that event
  // @ensures the completed meeting is no longer confirmed, so a second completion is refused
  test('a second completion is refused', () async {
    final state = _fold([reserved, confirmed, completedEvent()]);
    expect(state.lifecycle, MeetingLifecycleState.completed);
    await expectLater(completeMeetingDecider.decide(command, state).toList(), throwsA(isA<MeetingNotConfirmedError>()));
  });
}
