import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import 'direct_calendar_deletions/state.dart';
import 'record_meeting_deleted/command.dart';
import 'record_meeting_deleted/state.dart';

/// The direct deletion of one meeting and the meeting's lifecycle as the processor history folds it.
typedef DirectDeletionInput = ({DirectCalendarDeletionState deletion, RecordMeetingDeletedState history});

/// The processor `direct_deletion_translator`: a direct deletion becomes `record_meeting_deleted` while the meeting is
/// confirmed, rescheduling, or canceling (the source states of `record_direct_deletion`). Other states send nothing.
final directDeletionTranslatorSaga = saga<DirectDeletionInput, RecordMeetingDeletedCommand>((input) async* {
  final lifecycle = input.history.lifecycle;
  if (lifecycle != MeetingLifecycleState.confirmed &&
      lifecycle != MeetingLifecycleState.rescheduling &&
      lifecycle != MeetingLifecycleState.canceling) {
    return;
  }
  yield RecordMeetingDeletedCommand(meetingId: input.deletion.meetingId);
});
