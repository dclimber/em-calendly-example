import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_deletion/direct_calendar_deletions/view.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_deletion/record_meeting_deleted/command.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_deletion/record_meeting_deleted/state.dart';
import 'package:em_calendly_example/slices/apply_direct_calendar_deletion/saga.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

Future<List<RecordMeetingDeletedCommand>> _react(RecordMeetingDeletedState history) async {
  final deletion = directCalendarDeletionsView.evolve(directCalendarDeletionsView.initialState, deletedDirectly())!;
  return directDeletionTranslatorSaga.react((deletion: deletion, history: history)).toList();
}

void main() {
  // @requires a confirmed meeting and a direct deletion of its calendar event
  // @ensures scenario direct_deletion_cancels_the_meeting: the processor sends one record_meeting_deleted
  test('direct_deletion_cancels_the_meeting', () async {
    final commands = await _react(lifecycleOf([reservedEvent(), confirmedEvent()]));
    expect(commands, [deleteCommand()]);
  });

  // @requires a meeting in rescheduling and a direct deletion of its calendar event
  // @ensures scenario direct_deletion_ends_a_reschedule_in_progress: the processor sends the command
  test('direct_deletion_ends_a_reschedule_in_progress', () async {
    final commands = await _react(lifecycleOf([reservedEvent(), confirmedEvent(), rescheduleRequestedEvent()]));
    expect(commands, [deleteCommand()]);
  });

  // @requires a completed meeting and a direct deletion
  // @ensures scenario direct_deletion_after_the_end_is_dropped: expect_no_dispatch for record_meeting_deleted
  test('direct_deletion_after_the_end_is_dropped', () async {
    expect(await _react(lifecycleOf([reservedEvent(), confirmedEvent(), completedEvent()])), isEmpty);
    expect(
      await _react(lifecycleOf([reservedEvent(), confirmedEvent(), cancellationRequestedEvent(), canceledEvent()])),
      isEmpty,
    );
    expect(await _react(lifecycleOf([reservedEvent(), bookingFailedEvent()])), isEmpty);
  });

  // @requires any history with any lifecycle and a direct deletion
  // @ensures the processor sends a command exactly when the meeting is confirmed, rescheduling, or canceling
  test('dispatch exactly when confirmed, rescheduling, or canceling', () async {
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
      final expected =
          lifecycle == MeetingLifecycleState.confirmed ||
          lifecycle == MeetingLifecycleState.rescheduling ||
          lifecycle == MeetingLifecycleState.canceling;
      expect(commands.length, expected ? 1 : 0, reason: 'lifecycle: $lifecycle');
    }
  });
}
