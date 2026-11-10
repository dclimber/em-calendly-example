import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/complete_meeting_cancellation/complete_cancellation/command.dart';
import 'package:em_calendly_example/slices/complete_meeting_cancellation/complete_cancellation/decider.dart';
import 'package:em_calendly_example/slices/complete_meeting_cancellation/complete_cancellation/errors.dart';
import 'package:em_calendly_example/slices/complete_meeting_cancellation/complete_cancellation/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

CompleteCancellationState _fold(List<MeetingsEvent> history) =>
    history.fold(completeCancellationDecider.initialState, completeCancellationDecider.evolve);

void main() {
  final command = CompleteCancellationCommand(meetingId: MeetingId('meeting-1'));

  // @requires a meeting in canceling: reserved, confirmed, and a cancellation requested
  // @ensures scenario deleted_event_cancels_the_meeting: the decider emits one meeting_canceled for the meeting
  test('deleted_event_cancels_the_meeting', () async {
    final history = [reservedEvent(), confirmedEvent(), cancellationRequestedEvent()];
    final events = await completeCancellationDecider.decide(command, _fold(history)).toList();
    expect(events, [canceledEvent()]);
  });

  // @requires a meeting outside canceling: never reserved, pending, confirmed, booking_failed, rescheduling, canceled,
  // or completed
  // @ensures the decider refuses with MeetingNotCancelingError in each of those states
  test('a meeting outside canceling is refused', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [reservedEvent()],
      [reservedEvent(), confirmedEvent()],
      [
        reservedEvent(),
        MeetingBookingFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('busy')),
      ],
      [
        reservedEvent(),
        confirmedEvent(),
        MeetingRescheduleRequestedEvent(
          meetingId: MeetingId('meeting-1'),
          hostId: HostId('alice-employee-id'),
          requestedBy: RequestedBy('bob-employee-id'),
          newSlotStart: NewSlotStart(DateTime.utc(2027, 3, 16, 14)),
          newSlotEnd: NewSlotEnd(DateTime.utc(2027, 3, 16, 14, 30)),
          calendarEventId: CalendarEventId('cal-1'),
          participants: Participants.empty(),
        ),
      ],
      [
        reservedEvent(),
        confirmedEvent(),
        cancellationRequestedEvent(),
        canceledEvent(),
      ],
      [reservedEvent(), confirmedEvent(), MeetingCompletedEvent(meetingId: MeetingId('meeting-1'))],
    ];
    for (final history in histories) {
      await expectLater(
        completeCancellationDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<MeetingNotCancelingError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a completed cancellation, then a repeated calendar event for the same meeting
  // @ensures the repeat is refused, so the cancellation completes once
  test('a repeated calendar event is refused after completion', () async {
    final history = [reservedEvent(), confirmedEvent(), cancellationRequestedEvent(), canceledEvent()];
    await expectLater(
      completeCancellationDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<MeetingNotCancelingError>()),
    );
  });

  // @requires a cancellation that failed: the meeting is back in confirmed
  // @ensures the decider refuses: a deleted calendar event then completes nothing
  test('a failed cancellation returns to confirmed and is refused', () async {
    final history = [reservedEvent(), confirmedEvent(), cancellationRequestedEvent(), cancellationFailedEvent()];
    await expectLater(
      completeCancellationDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<MeetingNotCancelingError>()),
    );
  });

  // @requires a cancellation whose calendar deletion was requested: still canceling
  // @ensures the decider still completes it: that event keeps the meeting in canceling
  test('the deletion request keeps the cancellation completable', () async {
    final history = [reservedEvent(), confirmedEvent(), cancellationRequestedEvent(), deletionRequestedEvent()];
    final events = await completeCancellationDecider.decide(command, _fold(history)).toList();
    expect(events, [canceledEvent()]);
  });
}
