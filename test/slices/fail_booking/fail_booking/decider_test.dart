import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_booking/fail_booking/decider.dart';
import 'package:em_calendly_example/slices/fail_booking/fail_booking/errors.dart';
import 'package:em_calendly_example/slices/fail_booking/fail_booking/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

FailBookingState _fold(List<MeetingsEvent> history) =>
    history.fold(failBookingDecider.initialState, failBookingDecider.evolve);

void main() {
  final reserved = reservedEvent();
  final command = commandFor('meeting-1', 'busy');

  // @requires a meeting reserved and still pending_calendar
  // @ensures scenario calendar_refuses_the_booking: the decider emits one booking_failed with the command's reason
  test('calendar_refuses_the_booking', () async {
    final events = await failBookingDecider.decide(command, _fold([reserved])).toList();
    expect(events, [
      MeetingBookingFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('busy')),
    ]);
  });

  // @requires a meeting that is not pending_calendar: never reserved, confirmed, or already booking_failed
  // @ensures the decider refuses with BookingNotPendingCalendarError in each of those states, and emits nothing
  test('a meeting outside pending_calendar is refused', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [reserved, MeetingConfirmedEvent(meetingId: reserved.meetingId, calendarEventId: CalendarEventId('cal-1'))],
      [reserved, MeetingBookingFailedEvent(meetingId: reserved.meetingId, failureReason: FailureReason('busy'))],
    ];
    for (final history in histories) {
      await expectLater(
        failBookingDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<BookingNotPendingCalendarError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a reservation folded alone, and then with a confirmation or booking failure
  // @ensures evolve tracks the lifecycle: pending_calendar, confirmed, and booking_failed
  test('evolve tracks the lifecycle', () {
    final d = failBookingDecider;
    expect(
      d.evolve(d.initialState, reserved),
      const FailBookingState(lifecycle: MeetingLifecycleState.pendingCalendar),
    );
    expect(
      d.evolve(
        _fold([reserved]),
        MeetingConfirmedEvent(meetingId: reserved.meetingId, calendarEventId: CalendarEventId('cal-1')),
      ),
      const FailBookingState(lifecycle: MeetingLifecycleState.confirmed),
    );
    expect(
      d.evolve(
        _fold([reserved]),
        MeetingBookingFailedEvent(meetingId: reserved.meetingId, failureReason: FailureReason('busy')),
      ),
      const FailBookingState(lifecycle: MeetingLifecycleState.bookingFailed),
    );
  });

  // @requires any reserved meeting, and a command built for it
  // @ensures exactly one event is emitted, and it names the command's meeting
  test('the event names the command meeting for every meeting', () async {
    for (final id in ['meeting-1', 'meeting-2', 'meeting-zz']) {
      final r = reservedEvent(meetingId: id);
      final events = await failBookingDecider.decide(commandFor(id, 'busy'), _fold([r])).toList();
      expect(events, hasLength(1));
      expect((events.single as MeetingBookingFailedEvent).meetingId, MeetingId(id));
    }
  });
}
