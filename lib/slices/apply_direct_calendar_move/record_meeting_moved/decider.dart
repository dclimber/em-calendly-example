import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `record_meeting_moved`.
///
/// The model's transition `record_direct_move` has the source states `confirmed` and `rescheduling`, and it leaves the
/// meeting `confirmed` with the moved times. The two invalid transitions give their exact reasons.
final recordMeetingMovedDecider = Decider<RecordMeetingMovedCommand, RecordMeetingMovedState, MeetingsEvent>(
  initialState: const RecordMeetingMovedState(),
  decide: (command, state) async* {
    final lifecycle = state.lifecycle;
    if (lifecycle == MeetingLifecycleState.canceling) throw const DirectMoveDuringCancellationError();
    if (lifecycle == MeetingLifecycleState.canceled ||
        lifecycle == MeetingLifecycleState.completed ||
        lifecycle == MeetingLifecycleState.bookingFailed) {
      throw const DirectMoveAfterTheEndError();
    }
    if (lifecycle != MeetingLifecycleState.confirmed && lifecycle != MeetingLifecycleState.rescheduling) {
      throw const MeetingNotConfirmedError();
    }
    yield MeetingMovedInCalendarEvent(
      meetingId: command.meetingId,
      newSlotStart: command.newSlotStart,
      newSlotEnd: command.newSlotEnd,
    );
  },
  evolve: meetingLifecycleView.evolve,
);
