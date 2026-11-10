import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_move/direct_calendar_moves/view.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_move/record_meeting_moved/command.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_move/record_meeting_moved/state.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_move/saga.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

Future<List<RecordMeetingMovedCommand>> _react(RecordMeetingMovedState history) async {
  final move = directCalendarMovesView.evolve(directCalendarMovesView.initialState, movedDirectly())!;
  return directMoveTranslatorSaga.react((move: move, history: history)).toList();
}

void main() {
  // @requires a confirmed meeting and a direct move of its calendar event
  // @ensures scenario direct_move_reschedules_the_meeting: the processor sends one record_meeting_moved with the moved times
  test('direct_move_reschedules_the_meeting', () async {
    final commands = await _react(lifecycleOf([reservedEvent(), confirmedEvent()]));
    expect(commands, [moveCommand()]);
  });

  // @requires a meeting in rescheduling and a direct move of its calendar event
  // @ensures scenario direct_move_replaces_a_reschedule_in_progress: the processor sends the command
  test('direct_move_replaces_a_reschedule_in_progress', () async {
    final commands = await _react(lifecycleOf([reservedEvent(), confirmedEvent(), rescheduleRequestedEvent()]));
    expect(commands, [moveCommand()]);
  });

  // @requires a meeting in canceling and a direct move
  // @ensures scenario direct_move_during_a_cancellation_is_dropped: expect_no_dispatch for record_meeting_moved
  test('direct_move_during_a_cancellation_is_dropped', () async {
    final commands = await _react(lifecycleOf([reservedEvent(), confirmedEvent(), cancellationRequestedEvent()]));
    expect(commands, isEmpty);
  });

  // @requires a meeting that has ended, or was canceled, and a direct move
  // @ensures scenario direct_move_after_the_end_is_dropped: expect_no_dispatch for record_meeting_moved
  test('direct_move_after_the_end_is_dropped', () async {
    expect(await _react(lifecycleOf([reservedEvent(), confirmedEvent(), completedEvent()])), isEmpty);
    expect(
      await _react(lifecycleOf([reservedEvent(), confirmedEvent(), cancellationRequestedEvent(), canceledEvent()])),
      isEmpty,
    );
  });

  // @requires any history with any lifecycle and a direct move
  // @ensures the processor sends a command exactly when the meeting is confirmed or rescheduling
  test('dispatch exactly when confirmed or rescheduling', () async {
    final histories = <List<MeetingsEvent>>[
      const [],
      [reservedEvent()],
      [reservedEvent(), confirmedEvent()],
      [reservedEvent(), confirmedEvent(), rescheduleRequestedEvent()],
      [reservedEvent(), confirmedEvent(), cancellationRequestedEvent()],
      [reservedEvent(), confirmedEvent(), cancellationRequestedEvent(), canceledEvent()],
      [reservedEvent(), confirmedEvent(), completedEvent()],
      [reservedEvent(), bookingFailedEvent()],
    ];
    for (final history in histories) {
      final lifecycle = lifecycleOf(history).lifecycle;
      final commands = await _react(lifecycleOf(history));
      final expected = lifecycle == MeetingLifecycleState.confirmed || lifecycle == MeetingLifecycleState.rescheduling;
      expect(commands.length, expected ? 1 : 0, reason: 'lifecycle: $lifecycle');
    }
  });
}
