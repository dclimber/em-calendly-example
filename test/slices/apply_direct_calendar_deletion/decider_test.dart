import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_deletion/record_meeting_deleted/decider.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_deletion/record_meeting_deleted/errors.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_deletion/record_meeting_deleted/state.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

RecordMeetingDeletedState _fold(List<MeetingsEvent> history) => lifecycleOf(history);

void main() {
  group('happy_path', () {
    // @requires a confirmed meeting
    // @ensures scenario direct_deletion_cancels_the_meeting: exactly meeting_canceled
    test('direct_deletion_cancels_the_meeting', () async {
      final events = await recordMeetingDeletedDecider
          .decide(deleteCommand(), _fold([reservedEvent(), confirmedEvent()]))
          .toList();
      expect(events, [canceledEvent()]);
    });
  });

  group('variant', () {
    // @requires a meeting in rescheduling
    // @ensures scenario direct_deletion_ends_a_reschedule_in_progress: the calendar cancellation ends the reschedule
    test('direct_deletion_ends_a_reschedule_in_progress', () async {
      final events = await recordMeetingDeletedDecider
          .decide(deleteCommand(), _fold([reservedEvent(), confirmedEvent(), rescheduleRequestedEvent()]))
          .toList();
      expect(events, [canceledEvent()]);
    });

    // @requires a meeting in canceling
    // @ensures the direct deletion completes the cancellation: exactly meeting_canceled
    test('direct_deletion_completes_a_cancellation_in_progress', () async {
      final events = await recordMeetingDeletedDecider
          .decide(deleteCommand(), _fold([reservedEvent(), confirmedEvent(), cancellationRequestedEvent()]))
          .toList();
      expect(events, [canceledEvent()]);
    });
  });

  group('state_violation', () {
    // @requires a meeting that has ended or was canceled, or whose booking failed
    // @ensures scenario direct_deletion_after_the_end_is_dropped: refused with the model's reason, no event
    test('direct_deletion_after_the_end_is_dropped', () async {
      final endedStates = {
        'completed': [reservedEvent(), confirmedEvent(), completedEvent()],
        'canceled': [reservedEvent(), confirmedEvent(), cancellationRequestedEvent(), canceledEvent()],
        'booking_failed': [reservedEvent(), bookingFailedEvent()],
      };
      for (final entry in endedStates.entries) {
        await expectLater(
          recordMeetingDeletedDecider.decide(deleteCommand(), _fold(entry.value)).toList(),
          throwsA(
            isA<DirectDeletionAfterTheEndError>().having(
              (e) => e.message,
              'message',
              'A meeting that has ended or was canceled ignores a direct deletion.',
            ),
          ),
          reason: entry.key,
        );
      }
    });
  });

  group('laws', () {
    // @requires every lifecycle state, including a meeting that is not reserved
    // @ensures the decider emits exactly one event for confirmed, rescheduling, and canceling, and refuses every other state
    test('the decider accepts exactly confirmed, rescheduling, and canceling', () async {
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
            state.lifecycle == MeetingLifecycleState.confirmed ||
            state.lifecycle == MeetingLifecycleState.rescheduling ||
            state.lifecycle == MeetingLifecycleState.canceling;
        if (accepted) {
          final events = await recordMeetingDeletedDecider.decide(deleteCommand(), state).toList();
          expect(events, hasLength(1), reason: entry.key);
        } else {
          await expectLater(
            recordMeetingDeletedDecider.decide(deleteCommand(), state).toList(),
            throwsA(isA<RecordMeetingDeletedError>()),
            reason: entry.key,
          );
        }
      }
    });

    // @requires any accepted deletion
    // @ensures the emitted event names the command's meeting
    test('the emitted event names the meeting of the command', () async {
      final events = await recordMeetingDeletedDecider
          .decide(
            deleteCommand(meetingId: 'meeting-9'),
            _fold([reservedEvent(meetingId: 'meeting-9'), confirmedEvent(meetingId: 'meeting-9')]),
          )
          .toList();
      expect(events.single, MeetingCanceledEvent(meetingId: MeetingId('meeting-9')));
    });
  });
}
