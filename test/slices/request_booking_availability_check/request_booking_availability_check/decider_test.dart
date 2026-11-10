import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_booking_availability_check/request_booking_availability_check/decider.dart';
import 'package:em_calendly_example/slices/request_booking_availability_check/request_booking_availability_check/errors.dart';
import 'package:em_calendly_example/slices/request_booking_availability_check/request_booking_availability_check/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

RequestBookingAvailabilityCheckState _fold(List<MeetingsEvent> history) =>
    history.fold(requestBookingAvailabilityCheckDecider.initialState, requestBookingAvailabilityCheckDecider.evolve);

void main() {
  final reserved = reservedEvent();
  final command = commandFor(reserved);

  // @requires a meeting reserved and still pending_calendar, with no check requested
  // @ensures scenario check_is_requested: the decider emits one booking_availability_check_requested for the slot
  test('check_is_requested', () async {
    final events = await requestBookingAvailabilityCheckDecider.decide(command, _fold([reserved])).toList();
    expect(events, [
      BookingAvailabilityCheckRequestedEvent(
        meetingId: reserved.meetingId,
        hostId: reserved.hostId,
        slotStart: reserved.slotStart,
        slotEnd: reserved.slotEnd,
      ),
    ]);
  });

  // @requires a meeting whose live check was already requested
  // @ensures the decider refuses the repeat with AvailabilityCheckAlreadyRequestedError, and emits nothing
  test('a repeated request is refused', () async {
    final history = [reserved, _requested(reserved)];
    await expectLater(
      requestBookingAvailabilityCheckDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<AvailabilityCheckAlreadyRequestedError>()),
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
        requestBookingAvailabilityCheckDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<MeetingNotPendingCalendarError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a reservation folded alone, and then with a check requested
  // @ensures evolve tracks the lifecycle: pending_calendar after reserve, check requested stays pending_calendar
  test('evolve tracks the lifecycle', () {
    final d = requestBookingAvailabilityCheckDecider;
    expect(
      d.evolve(d.initialState, reserved),
      const RequestBookingAvailabilityCheckState(lifecycle: MeetingLifecycleState.pendingCalendar),
    );
    expect(
      d.evolve(_fold([reserved]), _requested(reserved)),
      const RequestBookingAvailabilityCheckState(
        lifecycle: MeetingLifecycleState.pendingCalendar,
        checkRequested: true,
      ),
    );
  });

  // @requires any reserved slot, and a command built from it
  // @ensures the emitted event carries the command's meeting, host, and slot, and exactly one event is emitted
  test('the event repeats the command for every slot', () async {
    final slots = [
      (DateTime.utc(2027, 3, 15, 9), DateTime.utc(2027, 3, 15, 9, 30)),
      (DateTime.utc(2027, 12, 31, 23), DateTime.utc(2028, 1, 1)),
    ];
    for (final (start, end) in slots) {
      final r = reservedEvent(meetingId: 'meeting-${start.millisecond}', slotStart: start, slotEnd: end);
      final events = await requestBookingAvailabilityCheckDecider.decide(commandFor(r), _fold([r])).toList();
      expect(events, hasLength(1));
      final event = events.single as BookingAvailabilityCheckRequestedEvent;
      expect(event.meetingId, r.meetingId);
      expect(event.hostId, r.hostId);
      expect(event.slotStart, r.slotStart);
      expect(event.slotEnd, r.slotEnd);
    }
  });
}

BookingAvailabilityCheckRequestedEvent _requested(MeetingSlotReservedEvent r) => BookingAvailabilityCheckRequestedEvent(
  meetingId: r.meetingId,
  hostId: r.hostId,
  slotStart: r.slotStart,
  slotEnd: r.slotEnd,
);
