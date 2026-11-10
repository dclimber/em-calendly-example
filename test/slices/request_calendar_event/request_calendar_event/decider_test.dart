import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_calendar_event/request_calendar_event/command.dart';
import 'package:em_calendly_example/slices/request_calendar_event/request_calendar_event/decider.dart';
import 'package:em_calendly_example/slices/request_calendar_event/request_calendar_event/errors.dart';
import 'package:em_calendly_example/slices/request_calendar_event/request_calendar_event/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

RequestCalendarEventState _fold(List<MeetingsEvent> history) =>
    history.fold(requestCalendarEventDecider.initialState, requestCalendarEventDecider.evolve);

void main() {
  final reserved = reservedEvent();
  final command = RequestCalendarEventCommand(meetingId: reserved.meetingId);

  // @requires a meeting reserved, verified, and still pending_calendar, with no calendar event requested
  // @ensures scenario happy_path: the decider emits one calendar_event_requested for the meeting
  test('happy_path', () async {
    final events = await requestCalendarEventDecider.decide(command, _fold([reserved, verifiedEvent()])).toList();
    expect(events, [requestedEvent()]);
  });

  // @requires a meeting whose calendar event was already requested
  // @ensures the decider refuses the repeat with CalendarEventAlreadyRequestedError, and emits nothing
  test('a repeated request is refused', () async {
    final history = [reserved, verifiedEvent(), requestedEvent()];
    await expectLater(
      requestCalendarEventDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<CalendarEventAlreadyRequestedError>()),
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
        requestCalendarEventDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<MeetingNotPendingCalendarError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a reservation folded alone, and then with the calendar event requested
  // @ensures evolve tracks the lifecycle: pending_calendar after reserve, requested stays pending_calendar
  test('evolve tracks the lifecycle', () {
    final d = requestCalendarEventDecider;
    expect(
      d.evolve(d.initialState, reserved),
      const RequestCalendarEventState(lifecycle: MeetingLifecycleState.pendingCalendar),
    );
    expect(
      d.evolve(_fold([reserved]), requestedEvent()),
      const RequestCalendarEventState(lifecycle: MeetingLifecycleState.pendingCalendar, calendarEventRequested: true),
    );
  });

  // @requires any reserved meeting, and the command built from it
  // @ensures every request emits exactly one calendar_event_requested for the command's meeting
  test('the event repeats the command for every meeting', () async {
    for (final id in ['meeting-1', 'meeting-2', 'f1d91c85-3a90-593b-9d5e-7cb450033766']) {
      final r = reservedEvent(meetingId: id);
      final events = await requestCalendarEventDecider
          .decide(RequestCalendarEventCommand(meetingId: r.meetingId), _fold([r]))
          .toList();
      expect(events, [requestedEvent(meetingId: id)]);
    }
  });

  // @requires a meeting that is pending_calendar, and any number of requests before the repeat is folded
  // @ensures the decider emits at most one calendar_event_requested per meeting: the repeat is always refused
  test('at most one calendar_event_requested per meeting', () async {
    final history = [reserved, verifiedEvent()];
    final emitted = await requestCalendarEventDecider.decide(command, _fold(history)).toList();
    expect(emitted, hasLength(1));
    final afterRequest = [...history, ...emitted];
    await expectLater(
      requestCalendarEventDecider.decide(command, _fold(afterRequest)).toList(),
      throwsA(isA<CalendarEventAlreadyRequestedError>()),
    );
  });
}
