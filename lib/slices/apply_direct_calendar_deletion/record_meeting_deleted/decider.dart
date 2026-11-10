import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `record_meeting_deleted`.
///
/// The model's transition `record_direct_deletion` has the source states `confirmed`, `rescheduling`, and `canceling`,
/// and it leaves the meeting `canceled` with `meeting_canceled`. The calendar wins, so a deletion also ends a
/// cancellation in progress. The invalid transition `direct_deletion_after_the_end` gives its exact reason.
final recordMeetingDeletedDecider = Decider<RecordMeetingDeletedCommand, RecordMeetingDeletedState, MeetingsEvent>(
  initialState: const RecordMeetingDeletedState(),
  decide: (command, state) async* {
    final lifecycle = state.lifecycle;
    if (lifecycle == MeetingLifecycleState.canceled ||
        lifecycle == MeetingLifecycleState.completed ||
        lifecycle == MeetingLifecycleState.bookingFailed) {
      throw const DirectDeletionAfterTheEndError();
    }
    if (lifecycle != MeetingLifecycleState.confirmed &&
        lifecycle != MeetingLifecycleState.rescheduling &&
        lifecycle != MeetingLifecycleState.canceling) {
      throw const MeetingNotDeletableError();
    }
    yield MeetingCanceledEvent(meetingId: command.meetingId);
  },
  evolve: meetingLifecycleView.evolve,
);
