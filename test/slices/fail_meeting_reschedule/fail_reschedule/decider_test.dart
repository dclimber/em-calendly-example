import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_meeting_reschedule/fail_reschedule/decider.dart';
import 'package:em_calendly_example/slices/fail_meeting_reschedule/fail_reschedule/errors.dart';
import 'package:em_calendly_example/slices/fail_meeting_reschedule/fail_reschedule/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

FailRescheduleState _fold(List<MeetingsEvent> history) =>
    history.fold(failRescheduleDecider.initialState, failRescheduleDecider.evolve);

void main() {
  final reserved = reservedEvent();
  final confirmed = confirmedEvent();
  final requested = rescheduleRequestedEvent();
  final rescheduling = _fold([reserved, confirmed, requested]);
  final command = commandFor('meeting-1', 'busy');

  // @requires a meeting in rescheduling, after its reschedule was requested
  // @ensures scenario busy_host_keeps_the_original_time: the decider emits one reschedule_failed with the command's reason
  test('busy_host_keeps_the_original_time', () async {
    final events = await failRescheduleDecider.decide(command, rescheduling).toList();
    expect(events, [
      MeetingRescheduleFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('busy')),
    ]);
  });

  // @requires a meeting in rescheduling, and the calendar system refuses the change
  // @ensures scenario update_failure_keeps_the_original_time: the decider emits one reschedule_failed with that reason
  test('update_failure_keeps_the_original_time', () async {
    final events = await failRescheduleDecider.decide(commandFor('meeting-1', 'refused'), rescheduling).toList();
    expect(events, [
      MeetingRescheduleFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('refused')),
    ]);
  });

  // @requires a meeting in rescheduling, and an unanswered availability check
  // @ensures scenario unanswered_check_keeps_the_original_time: the decider emits one reschedule_failed
  test('unanswered_check_keeps_the_original_time', () async {
    final events = await failRescheduleDecider.decide(commandFor('meeting-1', 'unanswered'), rescheduling).toList();
    expect(events, hasLength(1));
    expect(events.single, isA<MeetingRescheduleFailedEvent>());
  });

  // @requires a meeting that is not rescheduling: never reserved, confirmed, booking_failed, or already rescheduled
  // @ensures the decider refuses with MeetingNotReschedulingError in each of those states, and emits nothing
  test('a meeting outside rescheduling is refused', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [reserved],
      [reserved, confirmed],
      [reserved, confirmed, requested, MeetingRescheduledEvent(meetingId: MeetingId('meeting-1'))],
      [
        reserved,
        confirmed,
        requested,
        MeetingRescheduleFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('busy')),
      ],
      [reserved, MeetingBookingFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('busy'))],
    ];
    for (final history in histories) {
      await expectLater(
        failRescheduleDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<MeetingNotReschedulingError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a reservation, a confirmation, a reschedule request, and a failure, folded in turn
  // @ensures evolve tracks the lifecycle: pending_calendar, confirmed, rescheduling, and confirmed again after the failure
  test('evolve tracks the lifecycle', () {
    final d = failRescheduleDecider;
    expect(
      d.evolve(d.initialState, reserved),
      const FailRescheduleState(lifecycle: MeetingLifecycleState.pendingCalendar),
    );
    expect(
      d.evolve(_fold([reserved]), confirmed),
      const FailRescheduleState(lifecycle: MeetingLifecycleState.confirmed),
    );
    expect(d.evolve(_fold([reserved, confirmed]), requested), rescheduling);
    expect(
      d.evolve(
        rescheduling,
        MeetingRescheduleFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('busy')),
      ),
      const FailRescheduleState(lifecycle: MeetingLifecycleState.confirmed),
    );
  });

  // @requires any meeting in rescheduling, and a command built for it
  // @ensures exactly one event is emitted, and it names the command's meeting
  test('the event names the command meeting for every meeting', () async {
    for (final id in ['meeting-1', 'meeting-2', 'meeting-zz']) {
      final history = [
        reservedEvent(meetingId: id),
        confirmedEvent(meetingId: id),
        rescheduleRequestedEvent(meetingId: id),
      ];
      final events = await failRescheduleDecider.decide(commandFor(id, 'busy'), _fold(history)).toList();
      expect(events, hasLength(1));
      expect((events.single as MeetingRescheduleFailedEvent).meetingId, MeetingId(id));
    }
  });
}
