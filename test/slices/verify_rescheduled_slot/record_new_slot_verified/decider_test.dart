import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/verify_rescheduled_slot/record_new_slot_verified/decider.dart';
import 'package:em_calendly_example/slices/verify_rescheduled_slot/record_new_slot_verified/errors.dart';
import 'package:em_calendly_example/slices/verify_rescheduled_slot/record_new_slot_verified/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

RecordNewSlotVerifiedState _fold(List<MeetingsEvent> history) =>
    history.fold(recordNewSlotVerifiedDecider.initialState, recordNewSlotVerifiedDecider.evolve);

void main() {
  final reserved = reservedEvent();
  final requested = rescheduleRequestedEvent();
  final rescheduling = [reserved, confirmedEvent(), requested];
  final command = commandFor('meeting-1');
  final verified = NewSlotVerifiedEvent(meetingId: MeetingId('meeting-1'));

  // @requires a meeting in rescheduling, with its new slot not yet verified
  // @ensures scenario free_host_verifies_the_slot: the decider emits one new_slot_verified for the meeting
  test('free_host_verifies_the_slot', () async {
    final events = await recordNewSlotVerifiedDecider.decide(command, _fold(rescheduling)).toList();
    expect(events, [NewSlotVerifiedEvent(meetingId: MeetingId('meeting-1'))]);
  });

  // @requires a meeting in rescheduling whose new slot was already verified for this reschedule request
  // @ensures the decider refuses the repeat with NewSlotAlreadyVerifiedError, and emits nothing
  test('a repeated verification is refused', () async {
    await expectLater(
      recordNewSlotVerifiedDecider.decide(command, _fold([...rescheduling, verified])).toList(),
      throwsA(isA<NewSlotAlreadyVerifiedError>()),
    );
  });

  // @requires a new reschedule request after an earlier verification of another new slot
  // @ensures the verification of the earlier request does not count: the decider emits one new_slot_verified again
  test('a new reschedule request resets the verification', () async {
    final again = rescheduleRequestedEvent(
      newSlotStart: DateTime.utc(2027, 3, 17, 9),
      newSlotEnd: DateTime.utc(2027, 3, 17, 9, 30),
    );
    final events = await recordNewSlotVerifiedDecider
        .decide(command, _fold([...rescheduling, verified, again]))
        .toList();
    expect(events, [NewSlotVerifiedEvent(meetingId: MeetingId('meeting-1'))]);
  });

  // @requires a meeting that is not rescheduling: never reserved, pending_calendar, confirmed, or booking_failed
  // @ensures the decider refuses with MeetingNotReschedulingError in each of those states
  test('a meeting outside rescheduling is refused', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [reserved],
      [reserved, confirmedEvent()],
      [reserved, MeetingBookingFailedEvent(meetingId: reserved.meetingId, failureReason: FailureReason('busy'))],
    ];
    for (final history in histories) {
      await expectLater(
        recordNewSlotVerifiedDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<MeetingNotReschedulingError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a reschedule request, and then its verification
  // @ensures evolve tracks the lifecycle: rescheduling after the request, and new slot verified after the verification
  test('evolve tracks the lifecycle', () {
    final d = recordNewSlotVerifiedDecider;
    expect(
      d.evolve(_fold([reserved, confirmedEvent()]), requested),
      const RecordNewSlotVerifiedState(lifecycle: MeetingLifecycleState.rescheduling),
    );
    expect(
      d.evolve(_fold(rescheduling), verified),
      const RecordNewSlotVerifiedState(lifecycle: MeetingLifecycleState.rescheduling, newSlotVerified: true),
    );
  });

  // @requires any rescheduling meeting, and a command built for it
  // @ensures exactly one event is emitted, and it names the command's meeting
  test('the event names the command meeting for every meeting', () async {
    for (final id in ['meeting-1', 'meeting-2', 'meeting-zz']) {
      final history = [
        reservedEvent(meetingId: id),
        confirmedEvent(meetingId: id),
        rescheduleRequestedEvent(meetingId: id),
      ];
      final events = await recordNewSlotVerifiedDecider.decide(commandFor(id), _fold(history)).toList();
      expect(events, hasLength(1));
      expect((events.single as NewSlotVerifiedEvent).meetingId, MeetingId(id));
    }
  });
}
