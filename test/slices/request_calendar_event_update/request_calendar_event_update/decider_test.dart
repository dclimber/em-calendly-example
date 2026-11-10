import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_calendar_event_update/request_calendar_event_update/command.dart';
import 'package:em_calendly_example/slices/request_calendar_event_update/request_calendar_event_update/decider.dart';
import 'package:em_calendly_example/slices/request_calendar_event_update/request_calendar_event_update/errors.dart';
import 'package:em_calendly_example/slices/request_calendar_event_update/request_calendar_event_update/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

RequestCalendarEventUpdateState _fold(List<MeetingsEvent> history) =>
    history.fold(requestCalendarEventUpdateDecider.initialState, requestCalendarEventUpdateDecider.evolve);

void main() {
  final reserved = reservedEvent();
  final requested = rescheduleRequestedEvent();
  final command = RequestCalendarEventUpdateCommand(
    meetingId: requested.meetingId,
    newSlotStart: requested.newSlotStart,
  );
  final rescheduling = [reserved, confirmedEvent(), requested];

  // @requires a meeting in rescheduling whose new slot is verified, and no calendar update requested yet
  // @ensures scenario happy_path: the decider emits one calendar_event_update_requested for the meeting and new slot
  test('happy_path', () async {
    final events = await requestCalendarEventUpdateDecider
        .decide(command, _fold([...rescheduling, newSlotVerifiedEvent()]))
        .toList();
    expect(events, [updateRequestedEvent()]);
  });

  // @requires a meeting whose calendar event update was already requested for this reschedule
  // @ensures the decider refuses the repeat with CalendarEventUpdateAlreadyRequestedError, and emits nothing
  test('a repeated request is refused', () async {
    final history = [...rescheduling, newSlotVerifiedEvent(), updateRequestedEvent()];
    await expectLater(
      requestCalendarEventUpdateDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<CalendarEventUpdateAlreadyRequestedError>()),
    );
  });

  // @requires a meeting that is not rescheduling: never reserved, confirmed, canceled, or after a completed reschedule
  // @ensures the decider refuses with MeetingNotReschedulingError in each of those states
  test('a meeting outside rescheduling is refused', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [reserved],
      [reserved, confirmedEvent()],
      [reserved, MeetingBookingFailedEvent(meetingId: reserved.meetingId, failureReason: FailureReason('busy'))],
      [
        ...rescheduling,
        newSlotVerifiedEvent(),
        updateRequestedEvent(),
        MeetingRescheduledEvent(meetingId: reserved.meetingId),
      ],
      [...rescheduling, MeetingCanceledEvent(meetingId: reserved.meetingId)],
    ];
    for (final history in histories) {
      await expectLater(
        requestCalendarEventUpdateDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<MeetingNotReschedulingError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a reschedule folded, then the update requested, then a new reschedule request
  // @ensures evolve tracks the lifecycle, and a new reschedule request resets the update flag
  test('evolve tracks the lifecycle and resets per reschedule request', () {
    final d = requestCalendarEventUpdateDecider;
    expect(
      d.evolve(d.initialState, reserved),
      const RequestCalendarEventUpdateState(lifecycle: MeetingLifecycleState.pendingCalendar),
    );
    expect(
      _fold([...rescheduling, updateRequestedEvent()]),
      const RequestCalendarEventUpdateState(
        lifecycle: MeetingLifecycleState.rescheduling,
        calendarEventUpdateRequested: true,
      ),
    );
    expect(
      d.evolve(_fold([...rescheduling, updateRequestedEvent()]), requested),
      const RequestCalendarEventUpdateState(lifecycle: MeetingLifecycleState.rescheduling),
    );
  });

  // @requires any rescheduling meeting, and the command built from it
  // @ensures every request emits exactly one calendar_event_update_requested for the command's meeting and new slot
  test('the event repeats the command for every meeting', () async {
    for (final id in ['meeting-1', 'meeting-2', 'f1d91c85-3a90-593b-9d5e-7cb450033766']) {
      final r = rescheduleRequestedEvent(meetingId: id);
      final events = await requestCalendarEventUpdateDecider
          .decide(
            RequestCalendarEventUpdateCommand(meetingId: r.meetingId, newSlotStart: r.newSlotStart),
            _fold([reservedEvent(meetingId: id), confirmedEvent(meetingId: id), r]),
          )
          .toList();
      expect(events, [updateRequestedEvent(meetingId: id)]);
    }
  });

  // @requires a meeting in rescheduling, and any number of requests before the repeat is folded
  // @ensures the decider emits at most one calendar_event_update_requested per reschedule: the repeat is always refused
  test('at most one calendar_event_update_requested per reschedule', () async {
    final history = [...rescheduling, newSlotVerifiedEvent()];
    final emitted = await requestCalendarEventUpdateDecider.decide(command, _fold(history)).toList();
    expect(emitted, hasLength(1));
    await expectLater(
      requestCalendarEventUpdateDecider.decide(command, _fold([...history, ...emitted])).toList(),
      throwsA(isA<CalendarEventUpdateAlreadyRequestedError>()),
    );
  });
}
