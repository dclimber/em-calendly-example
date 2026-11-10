import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_meeting_cancellation/fail_cancellation/decider.dart';
import 'package:em_calendly_example/slices/fail_meeting_cancellation/fail_cancellation/errors.dart';
import 'package:em_calendly_example/slices/fail_meeting_cancellation/fail_cancellation/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

FailCancellationState _fold(List<MeetingsEvent> history) =>
    history.fold(failCancellationDecider.initialState, failCancellationDecider.evolve);

void main() {
  final reserved = reservedEvent();
  final confirmed = confirmedEvent();
  final requested = cancellationRequestedEvent();
  final canceling = _fold([reserved, confirmed, requested]);

  // @requires a meeting in canceling, after its cancellation was requested
  // @ensures scenario deletion_failure_keeps_the_meeting: the decider emits one cancellation_failed with the command's reason
  test('deletion_failure_keeps_the_meeting', () async {
    final events = await failCancellationDecider.decide(commandFor('meeting-1', 'refused'), canceling).toList();
    expect(events, [
      MeetingCancellationFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('refused')),
    ]);
  });

  // @requires a meeting that is not canceling: never reserved, confirmed, rescheduling, canceled, or already failed
  // @ensures the decider refuses with MeetingNotCancelingError in each of those states, and emits nothing
  test('a meeting outside canceling is refused', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [reserved],
      [reserved, confirmed],
      [
        reserved,
        confirmed,
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
      [reserved, confirmed, requested, MeetingCanceledEvent(meetingId: MeetingId('meeting-1'))],
      [
        reserved,
        confirmed,
        requested,
        MeetingCancellationFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('refused')),
      ],
      [reserved, MeetingBookingFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('busy'))],
    ];
    for (final history in histories) {
      await expectLater(
        failCancellationDecider.decide(commandFor('meeting-1', 'refused'), _fold(history)).toList(),
        throwsA(isA<MeetingNotCancelingError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a reservation, a confirmation, a cancellation request, and a failure, folded in turn
  // @ensures evolve tracks the lifecycle: pending_calendar, confirmed, canceling, and confirmed again after the failure
  test('evolve tracks the lifecycle', () {
    final d = failCancellationDecider;
    expect(
      d.evolve(d.initialState, reserved),
      const FailCancellationState(lifecycle: MeetingLifecycleState.pendingCalendar),
    );
    expect(
      d.evolve(_fold([reserved]), confirmed),
      const FailCancellationState(lifecycle: MeetingLifecycleState.confirmed),
    );
    expect(d.evolve(_fold([reserved, confirmed]), requested), canceling);
    expect(
      d.evolve(
        canceling,
        MeetingCancellationFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('refused')),
      ),
      const FailCancellationState(lifecycle: MeetingLifecycleState.confirmed),
    );
  });

  // @requires any meeting in canceling, and a command built for it
  // @ensures exactly one event is emitted, and it names the command's meeting
  test('the event names the command meeting for every meeting', () async {
    for (final id in ['meeting-1', 'meeting-2', 'meeting-zz']) {
      final history = [
        reservedEvent(meetingId: id),
        confirmedEvent(meetingId: id),
        cancellationRequestedEvent(meetingId: id),
      ];
      final events = await failCancellationDecider.decide(commandFor(id, 'refused'), _fold(history)).toList();
      expect(events, hasLength(1));
      expect((events.single as MeetingCancellationFailedEvent).meetingId, MeetingId(id));
    }
  });

  // @requires a canceling meeting, and a failure reason
  // @ensures property: the emitted reason equals the command's reason for any reason text
  test('property: the emitted reason is the command reason', () async {
    for (final reason in ['refused', 'calendar_refused', 'x', 'Something else entirely']) {
      final events = await failCancellationDecider.decide(commandFor('meeting-1', reason), canceling).toList();
      expect((events.single as MeetingCancellationFailedEvent).failureReason, FailureReason(reason));
    }
  });
}
