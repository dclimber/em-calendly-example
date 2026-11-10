import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/confirm_booked_meeting/confirm_meeting/decider.dart';
import 'package:em_calendly_example/slices/confirm_booked_meeting/confirm_meeting/errors.dart';
import 'package:em_calendly_example/slices/confirm_booked_meeting/confirm_meeting/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

ConfirmMeetingState _fold(List<MeetingsEvent> history) =>
    history.fold(confirmMeetingDecider.initialState, confirmMeetingDecider.evolve);

void main() {
  final requested = requestedEvent();
  final command = commandFor('meeting-1');

  // @requires a meeting whose calendar event was requested, so it is pending_calendar
  // @ensures scenario created_event_confirms_the_meeting: the decider emits one meeting_confirmed for the meeting
  test('created_event_confirms_the_meeting', () async {
    final events = await confirmMeetingDecider.decide(command, _fold([requested])).toList();
    expect(events, [
      MeetingConfirmedEvent(meetingId: MeetingId('meeting-1'), calendarEventId: CalendarEventId('cal-1')),
    ]);
  });

  // @requires a meeting outside pending_calendar: never reserved, confirmed, or booking_failed
  // @ensures the decider refuses with MeetingNotAwaitingConfirmationError in each of those states
  test('a meeting outside pending_calendar is refused', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [
        reservedEvent(),
        MeetingConfirmedEvent(meetingId: MeetingId('meeting-1'), calendarEventId: CalendarEventId('cal-0')),
      ],
      [
        reservedEvent(),
        MeetingBookingFailedEvent(meetingId: MeetingId('meeting-1'), failureReason: FailureReason('busy')),
      ],
    ];
    for (final history in histories) {
      await expectLater(
        confirmMeetingDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<MeetingNotAwaitingConfirmationError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a reservation, then a confirmed meeting, then a repeated calendar event for it
  // @ensures the repeat is refused, so a meeting is confirmed once
  test('a repeated calendar event is refused after confirmation', () async {
    final confirmed = MeetingConfirmedEvent(
      meetingId: MeetingId('meeting-1'),
      calendarEventId: CalendarEventId('cal-1'),
    );
    await expectLater(
      confirmMeetingDecider.decide(command, _fold([requested, confirmed])).toList(),
      throwsA(isA<MeetingNotAwaitingConfirmationError>()),
    );
  });

  // @requires a reservation folded alone, and then a confirmation
  // @ensures evolve tracks the lifecycle: pending_calendar after reserve, and confirmed after confirmation
  test('evolve tracks the lifecycle', () {
    final d = confirmMeetingDecider;
    expect(
      d.evolve(d.initialState, reservedEvent()),
      const ConfirmMeetingState(lifecycle: MeetingLifecycleState.pendingCalendar),
    );
    expect(
      d.evolve(
        _fold([reservedEvent()]),
        MeetingConfirmedEvent(meetingId: MeetingId('meeting-1'), calendarEventId: CalendarEventId('cal-1')),
      ),
      const ConfirmMeetingState(lifecycle: MeetingLifecycleState.confirmed),
    );
  });
}
