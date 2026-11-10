import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/complete_meeting_reschedule/complete_reschedule/command.dart';
import 'package:em_calendly_example/slices/complete_meeting_reschedule/complete_reschedule/decider.dart';
import 'package:em_calendly_example/slices/complete_meeting_reschedule/complete_reschedule/errors.dart';
import 'package:em_calendly_example/slices/complete_meeting_reschedule/complete_reschedule/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

CompleteRescheduleState _fold(List<MeetingsEvent> history) =>
    history.fold(completeRescheduleDecider.initialState, completeRescheduleDecider.evolve);

void main() {
  final command = CompleteRescheduleCommand(meetingId: MeetingId('meeting-1'));

  // @requires a meeting in rescheduling: reserved, confirmed, and a reschedule requested
  // @ensures scenario moved_event_completes_the_reschedule: the decider emits one meeting_rescheduled for the meeting
  test('moved_event_completes_the_reschedule', () async {
    final history = [reservedEvent(), confirmedEvent(), rescheduleRequestedEvent()];
    final events = await completeRescheduleDecider.decide(command, _fold(history)).toList();
    expect(events, [rescheduledEvent()]);
  });

  // @requires a meeting outside rescheduling: never reserved, pending, confirmed, booking_failed, canceling, canceled,
  // or completed
  // @ensures the decider refuses with MeetingNotReschedulingError in each of those states
  test('a meeting outside rescheduling is refused', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [reservedEvent()],
      [reservedEvent(), confirmedEvent()],
      [
        reservedEvent(),
        MeetingBookingFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('busy')),
      ],
      [reservedEvent(), confirmedEvent(), cancellationRequestedEvent()],
      [
        reservedEvent(),
        confirmedEvent(),
        cancellationRequestedEvent(),
        MeetingCanceledEvent(meetingId: MeetingId('meeting-1')),
      ],
      [reservedEvent(), confirmedEvent(), MeetingCompletedEvent(meetingId: MeetingId('meeting-1'))],
    ];
    for (final history in histories) {
      await expectLater(
        completeRescheduleDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<MeetingNotReschedulingError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a completed reschedule, then a repeated calendar event for the same meeting
  // @ensures the repeat is refused, so the reschedule completes once
  test('a repeated calendar event is refused after completion', () async {
    final history = [reservedEvent(), confirmedEvent(), rescheduleRequestedEvent(), rescheduledEvent()];
    await expectLater(
      completeRescheduleDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<MeetingNotReschedulingError>()),
    );
  });

  // @requires a reschedule whose new slot is verified and whose calendar update was requested: still rescheduling
  // @ensures the decider still completes it: those events keep the meeting in rescheduling
  test('the events inside a reschedule keep it completable', () async {
    final history = [
      reservedEvent(),
      confirmedEvent(),
      rescheduleRequestedEvent(),
      newSlotVerifiedEvent(),
      updateRequestedEvent(),
    ];
    final events = await completeRescheduleDecider.decide(command, _fold(history)).toList();
    expect(events, [rescheduledEvent()]);
  });
}
