import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_calendar_event_deletion/request_calendar_event_deletion/command.dart';
import 'package:em_calendly_example/slices/request_calendar_event_deletion/request_calendar_event_deletion/decider.dart';
import 'package:em_calendly_example/slices/request_calendar_event_deletion/request_calendar_event_deletion/errors.dart';
import 'package:em_calendly_example/slices/request_calendar_event_deletion/request_calendar_event_deletion/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

RequestCalendarEventDeletionState _fold(List<MeetingsEvent> history) =>
    history.fold(requestCalendarEventDeletionDecider.initialState, requestCalendarEventDeletionDecider.evolve);

void main() {
  final requested = cancellationRequestedEvent();
  final command = RequestCalendarEventDeletionCommand(meetingId: requested.meetingId);
  final confirmed = confirmedEvent();

  // @requires a meeting confirmed, then its cancellation requested (canceling), with no deletion requested yet
  // @ensures scenario happy_path: the decider emits one calendar_event_deletion_requested for the meeting
  test('happy_path', () async {
    final events = await requestCalendarEventDeletionDecider
        .decide(command, _fold([reservedEvent(), confirmed, requested]))
        .toList();
    expect(events, [deletionRequestedEvent()]);
  });

  // @requires a canceling meeting whose calendar event deletion was already requested
  // @ensures the decider refuses the repeat with CalendarEventDeletionAlreadyRequestedError, and emits nothing
  test('a repeated request is refused', () async {
    final history = [reservedEvent(), confirmed, requested, deletionRequestedEvent()];
    await expectLater(
      requestCalendarEventDeletionDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<CalendarEventDeletionAlreadyRequestedError>()),
    );
  });

  // @requires a meeting that is not canceling: never canceled, confirmed, canceled, or pending_calendar
  // @ensures the decider refuses with MeetingNotCancelingError in each of those states
  test('a meeting outside canceling is refused', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [reservedEvent()],
      [reservedEvent(), confirmed],
      [reservedEvent(), confirmed, requested, canceledEvent()],
      [reservedEvent(), confirmed, requested, cancellationFailedEvent()],
    ];
    for (final history in histories) {
      await expectLater(
        requestCalendarEventDeletionDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<MeetingNotCancelingError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a canceling meeting, then a failed cancellation, then a new cancellation
  // @ensures the new cancellation is a new request: its deletion can be requested again
  test('a new cancellation after a failed one may request the deletion again', () async {
    final history = [
      reservedEvent(),
      confirmed,
      requested,
      deletionRequestedEvent(),
      cancellationFailedEvent(),
      requested,
    ];
    final events = await requestCalendarEventDeletionDecider.decide(command, _fold(history)).toList();
    expect(events, [deletionRequestedEvent()]);
  });

  // @requires a meeting that is canceled directly (meeting_canceled) while it is canceling
  // @ensures the decider refuses the request, because the meeting is no longer canceling
  test('a directly canceled meeting is refused', () async {
    await expectLater(
      requestCalendarEventDeletionDecider
          .decide(command, _fold([reservedEvent(), confirmed, requested, canceledEvent()]))
          .toList(),
      throwsA(isA<MeetingNotCancelingError>()),
    );
  });

  // @requires the events folded one by one
  // @ensures evolve tracks canceling, the deletion request, and the failure back to confirmed
  test('evolve tracks the lifecycle', () {
    final d = requestCalendarEventDeletionDecider;
    expect(
      d.evolve(d.initialState, requested),
      const RequestCalendarEventDeletionState(lifecycle: MeetingLifecycleState.canceling),
    );
    expect(
      d.evolve(_fold([requested]), deletionRequestedEvent()),
      const RequestCalendarEventDeletionState(
        lifecycle: MeetingLifecycleState.canceling,
        calendarDeletionRequested: true,
      ),
    );
    expect(
      d.evolve(_fold([requested]), cancellationFailedEvent()),
      const RequestCalendarEventDeletionState(lifecycle: MeetingLifecycleState.confirmed),
    );
  });

  // @requires any canceling meeting, and the command built from it
  // @ensures every request emits exactly one calendar_event_deletion_requested for the command's meeting
  test('the event repeats the command for every meeting', () async {
    for (final id in ['meeting-1', 'meeting-2', 'f1d91c85-3a90-593b-9d5e-7cb450033766']) {
      final r = cancellationRequestedEvent(meetingId: id);
      final events = await requestCalendarEventDeletionDecider
          .decide(RequestCalendarEventDeletionCommand(meetingId: r.meetingId), _fold([r]))
          .toList();
      expect(events, [deletionRequestedEvent(meetingId: id)]);
    }
  });

  // @requires a canceling meeting, and any number of requests before the repeat is folded
  // @ensures the decider emits at most one calendar_event_deletion_requested per cancellation: the repeat is refused
  test('at most one calendar_event_deletion_requested per cancellation', () async {
    final history = [requested];
    final emitted = await requestCalendarEventDeletionDecider.decide(command, _fold(history)).toList();
    expect(emitted, hasLength(1));
    await expectLater(
      requestCalendarEventDeletionDecider.decide(command, _fold([...history, ...emitted])).toList(),
      throwsA(isA<CalendarEventDeletionAlreadyRequestedError>()),
    );
  });
}
