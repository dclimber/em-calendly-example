import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_reschedule_availability_check/request_reschedule_availability_check/decider.dart';
import 'package:em_calendly_example/slices/request_reschedule_availability_check/request_reschedule_availability_check/errors.dart';
import 'package:em_calendly_example/slices/request_reschedule_availability_check/request_reschedule_availability_check/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

RequestRescheduleAvailabilityCheckState _fold(List<MeetingsEvent> history) => history.fold(
  requestRescheduleAvailabilityCheckDecider.initialState,
  requestRescheduleAvailabilityCheckDecider.evolve,
);

void main() {
  final reserved = reservedEvent();
  final confirmed = confirmedEvent();
  final requested = rescheduleRequestedEvent();
  final command = commandFor(requested);

  // @requires a meeting in rescheduling, with no check requested for the new time
  // @ensures scenario check_is_requested: the decider emits one reschedule_availability_check_requested for the new slot
  test('check_is_requested', () async {
    final events = await requestRescheduleAvailabilityCheckDecider
        .decide(command, _fold([reserved, confirmed, requested]))
        .toList();
    expect(events, [checkRequestedFor(requested)]);
  });

  // @requires a meeting in rescheduling whose live check was already requested
  // @ensures the decider refuses the repeat with RescheduleAvailabilityCheckAlreadyRequestedError, and emits nothing
  test('a repeated request is refused', () async {
    final history = [reserved, confirmed, requested, checkRequestedFor(requested)];
    await expectLater(
      requestRescheduleAvailabilityCheckDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<RescheduleAvailabilityCheckAlreadyRequestedError>()),
    );
  });

  // @requires a meeting that is not rescheduling: never reserved, pending, confirmed, moved, canceled, or completed
  // @ensures the decider refuses with MeetingNotReschedulingError in each of those states
  test('a meeting outside rescheduling is refused', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [reserved],
      [reserved, confirmed],
      [reserved, confirmed, requested, MeetingRescheduledEvent(meetingId: reserved.meetingId)],
      [reserved, confirmed, requested, movedInCalendarEvent()],
      [reserved, confirmed, canceledEvent()],
      [reserved, confirmed, MeetingCompletedEvent(meetingId: reserved.meetingId)],
    ];
    for (final history in histories) {
      await expectLater(
        requestRescheduleAvailabilityCheckDecider.decide(command, _fold(history)).toList(),
        throwsA(isA<MeetingNotReschedulingError>()),
        reason: 'history: $history',
      );
    }
  });

  // @requires a reschedule that was checked, and then a second reschedule of the same meeting
  // @ensures the second reschedule gets its own check: the first check does not refuse it
  test('a new reschedule is checked again', () async {
    final second = rescheduleRequestedEvent(
      newSlotStart: DateTime.utc(2027, 3, 18, 9),
      newSlotEnd: DateTime.utc(2027, 3, 18, 9, 30),
    );
    final history = [
      reserved,
      confirmed,
      requested,
      checkRequestedFor(requested),
      MeetingRescheduledEvent(meetingId: reserved.meetingId),
      second,
    ];
    final events = await requestRescheduleAvailabilityCheckDecider.decide(commandFor(second), _fold(history)).toList();
    expect(events, [checkRequestedFor(second)]);
  });

  // @requires the events of a meeting folded one by one
  // @ensures evolve tracks the lifecycle: rescheduling after the request, check requested stays rescheduling
  test('evolve tracks the lifecycle', () {
    final d = requestRescheduleAvailabilityCheckDecider;
    expect(
      d.evolve(_fold([reserved, confirmed]), requested),
      const RequestRescheduleAvailabilityCheckState(lifecycle: MeetingLifecycleState.rescheduling),
    );
    expect(
      d.evolve(_fold([reserved, confirmed, requested]), checkRequestedFor(requested)),
      RequestRescheduleAvailabilityCheckState(
        lifecycle: MeetingLifecycleState.rescheduling,
        checkedSlot: (start: requested.newSlotStart, end: requested.newSlotEnd),
      ),
    );
  });

  // @requires any rescheduling meeting, and a command built from its requested new slot
  // @ensures the emitted event carries the command's meeting, host, and new slot, and exactly one event is emitted
  test('the event repeats the command for every new slot', () async {
    final slots = [
      (DateTime.utc(2027, 3, 16, 14), DateTime.utc(2027, 3, 16, 14, 30)),
      (DateTime.utc(2027, 12, 31, 23), DateTime.utc(2028, 1, 1)),
    ];
    for (final (start, end) in slots) {
      final r = rescheduleRequestedEvent(newSlotStart: start, newSlotEnd: end);
      final events = await requestRescheduleAvailabilityCheckDecider
          .decide(commandFor(r), _fold([reserved, confirmed, r]))
          .toList();
      expect(events, hasLength(1));
      final event = events.single as RescheduleAvailabilityCheckRequestedEvent;
      expect(event.meetingId, r.meetingId);
      expect(event.hostId, r.hostId);
      expect(event.newSlotStart, r.newSlotStart);
      expect(event.newSlotEnd, r.newSlotEnd);
    }
  });
}
