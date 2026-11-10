import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/verify_booked_slot/record_booking_slot_verified/decider.dart';
import 'package:em_calendly_example/slices/verify_booked_slot/record_booking_slot_verified/errors.dart';
import 'package:em_calendly_example/slices/verify_booked_slot/record_booking_slot_verified/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

RecordBookingSlotVerifiedState _fold(List<MeetingsEvent> history) =>
    history.fold(recordBookingSlotVerifiedDecider.initialState, recordBookingSlotVerifiedDecider.evolve);

void main() {
  final reserved = reservedEvent();
  final command = commandFor('meeting-1');
  final verified = BookingSlotVerifiedEvent(meetingId: reserved.meetingId);

  // @requires a meeting reserved and still pending_calendar, with no slot verified
  // @ensures scenario free_host_verifies_the_slot: the decider emits one booking_slot_verified for the meeting
  test('free_host_verifies_the_slot', () async {
    final events = await recordBookingSlotVerifiedDecider.decide(command, _fold([reserved])).toList();
    expect(events, [BookingSlotVerifiedEvent(meetingId: MeetingId('meeting-1'))]);
  });

  // @requires a meeting whose booked slot was already verified
  // @ensures the decider refuses the repeat with BookingSlotAlreadyVerifiedError, and emits nothing
  test('a repeated verification is refused', () async {
    await expectLater(
      recordBookingSlotVerifiedDecider.decide(command, _fold([reserved, verified])).toList(),
      throwsA(isA<BookingSlotAlreadyVerifiedError>()),
    );
  });

  // @requires a meeting that is not pending_calendar: never reserved, confirmed, or booking_failed
  // @ensures the decider refuses with MeetingNotPendingCalendarError in each of those states
  test('a meeting outside pending_calendar is refused', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [reserved, MeetingConfirmedEvent(meetingId: reserved.meetingId, calendarEventId: CalendarEventId('cal-1'))],
      [reserved, MeetingBookingFailedEvent(meetingId: reserved.meetingId, failureReason: FailureReason('busy'))],
    ];
    for (final history in histories) {
      await expectLater(
        recordBookingSlotVerifiedDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<MeetingNotPendingCalendarError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a reservation folded alone, and then with a slot verified
  // @ensures evolve tracks the lifecycle: pending_calendar after reserve, and slot_verified after verification
  test('evolve tracks the lifecycle', () {
    final d = recordBookingSlotVerifiedDecider;
    expect(
      d.evolve(d.initialState, reserved),
      const RecordBookingSlotVerifiedState(lifecycle: MeetingLifecycleState.pendingCalendar),
    );
    expect(
      d.evolve(_fold([reserved]), verified),
      const RecordBookingSlotVerifiedState(lifecycle: MeetingLifecycleState.pendingCalendar, slotVerified: true),
    );
  });

  // @requires any reserved meeting, and a command built for it
  // @ensures exactly one event is emitted, and it names the command's meeting
  test('the event names the command meeting for every meeting', () async {
    for (final id in ['meeting-1', 'meeting-2', 'meeting-zz']) {
      final r = reservedEvent(meetingId: id);
      final events = await recordBookingSlotVerifiedDecider.decide(commandFor(id), _fold([r])).toList();
      expect(events, hasLength(1));
      expect((events.single as BookingSlotVerifiedEvent).meetingId, MeetingId(id));
    }
  });
}
