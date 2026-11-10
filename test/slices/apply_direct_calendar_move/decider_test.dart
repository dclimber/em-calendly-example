import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_move/record_meeting_moved/decider.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_move/record_meeting_moved/errors.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_move/record_meeting_moved/state.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

RecordMeetingMovedState _fold(List<MeetingsEvent> history) => lifecycleOf(history);

void main() {
  group('happy_path', () {
    // @requires a confirmed meeting
    // @ensures scenario direct_move_reschedules_the_meeting: exactly meeting_moved_in_calendar with the moved times
    test('direct_move_reschedules_the_meeting', () async {
      final events = await recordMeetingMovedDecider
          .decide(moveCommand(), _fold([reservedEvent(), confirmedEvent()]))
          .toList();
      expect(events, [
        MeetingMovedInCalendarEvent(
          meetingId: MeetingId('meeting-1'),
          newSlotStart: NewSlotStart(DateTime.utc(2027, 3, 16, 14)),
          newSlotEnd: NewSlotEnd(DateTime.utc(2027, 3, 16, 14, 30)),
        ),
      ]);
    });
  });

  group('variant', () {
    // @requires a meeting in rescheduling
    // @ensures scenario direct_move_replaces_a_reschedule_in_progress: the calendar time replaces the reschedule
    test('direct_move_replaces_a_reschedule_in_progress', () async {
      final events = await recordMeetingMovedDecider
          .decide(moveCommand(), _fold([reservedEvent(), confirmedEvent(), rescheduleRequestedEvent()]))
          .toList();
      expect(events, [
        MeetingMovedInCalendarEvent(
          meetingId: MeetingId('meeting-1'),
          newSlotStart: NewSlotStart(DateTime.utc(2027, 3, 16, 14)),
          newSlotEnd: NewSlotEnd(DateTime.utc(2027, 3, 16, 14, 30)),
        ),
      ]);
    });
  });

  group('state_violation', () {
    // @requires a meeting in canceling
    // @ensures scenario direct_move_during_a_cancellation_is_dropped: refused with the model's reason, no event
    test('direct_move_during_a_cancellation_is_dropped', () async {
      final history = _fold([reservedEvent(), confirmedEvent(), cancellationRequestedEvent()]);
      await expectLater(
        recordMeetingMovedDecider.decide(moveCommand(), history).toList(),
        throwsA(
          isA<DirectMoveDuringCancellationError>().having(
            (e) => e.message,
            'message',
            'A meeting that is being canceled ignores a direct move.',
          ),
        ),
      );
    });

    // @requires a meeting that has ended or was canceled, or whose booking failed
    // @ensures scenario direct_move_after_the_end_is_dropped: refused with the model's reason, no event
    test('direct_move_after_the_end_is_dropped', () async {
      final endedStates = {
        'completed': [reservedEvent(), confirmedEvent(), completedEvent()],
        'canceled': [reservedEvent(), confirmedEvent(), cancellationRequestedEvent(), canceledEvent()],
        'booking_failed': [reservedEvent(), bookingFailedEvent()],
      };
      for (final entry in endedStates.entries) {
        await expectLater(
          recordMeetingMovedDecider.decide(moveCommand(), _fold(entry.value)).toList(),
          throwsA(
            isA<DirectMoveAfterTheEndError>().having(
              (e) => e.message,
              'message',
              'A meeting that has ended or was canceled ignores a direct move.',
            ),
          ),
          reason: entry.key,
        );
      }
    });
  });

  group('laws', () {
    // @requires every lifecycle state, including a meeting that is not reserved
    // @ensures the decider emits exactly one event for confirmed and rescheduling, and refuses every other state
    test('the decider accepts exactly confirmed and rescheduling', () async {
      final histories = <String, List<MeetingsEvent>>{
        'not_reserved': const [],
        'pending_calendar': [reservedEvent()],
        'confirmed': [reservedEvent(), confirmedEvent()],
        'rescheduling': [reservedEvent(), confirmedEvent(), rescheduleRequestedEvent()],
        'canceling': [reservedEvent(), confirmedEvent(), cancellationRequestedEvent()],
        'canceled': [reservedEvent(), confirmedEvent(), cancellationRequestedEvent(), canceledEvent()],
        'completed': [reservedEvent(), confirmedEvent(), completedEvent()],
        'booking_failed': [reservedEvent(), bookingFailedEvent()],
      };
      for (final entry in histories.entries) {
        final state = _fold(entry.value);
        final accepted =
            state.lifecycle == MeetingLifecycleState.confirmed || state.lifecycle == MeetingLifecycleState.rescheduling;
        if (accepted) {
          final events = await recordMeetingMovedDecider.decide(moveCommand(), state).toList();
          expect(events, hasLength(1), reason: entry.key);
        } else {
          await expectLater(
            recordMeetingMovedDecider.decide(moveCommand(), state).toList(),
            throwsA(isA<RecordMeetingMovedError>()),
            reason: entry.key,
          );
        }
      }
    });

    // @requires any accepted move
    // @ensures the emitted event carries exactly the command's moved times
    test('the emitted event carries the moved times', () async {
      final start = DateTime.utc(2027, 5, 2, 8);
      final end = DateTime.utc(2027, 5, 2, 8, 45);
      final events = await recordMeetingMovedDecider
          .decide(moveCommand(movedStart: start, movedEnd: end), _fold([reservedEvent(), confirmedEvent()]))
          .toList();
      final moved = events.single as MeetingMovedInCalendarEvent;
      expect(moved.newSlotStart, NewSlotStart(start));
      expect(moved.newSlotEnd, NewSlotEnd(end));
    });
  });
}
