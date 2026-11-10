import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import 'direct_calendar_moves/state.dart';
import 'record_meeting_moved/command.dart';
import 'record_meeting_moved/state.dart';

/// The direct move of one meeting and the meeting's lifecycle as the processor history folds it.
typedef DirectMoveInput = ({DirectCalendarMoveState move, RecordMeetingMovedState history});

/// The processor `direct_move_translator`: a direct move becomes `record_meeting_moved` only while the meeting is
/// confirmed or rescheduling (the source states of `record_direct_move`). Other states send nothing.
final directMoveTranslatorSaga = saga<DirectMoveInput, RecordMeetingMovedCommand>((input) async* {
  final lifecycle = input.history.lifecycle;
  if (lifecycle != MeetingLifecycleState.confirmed && lifecycle != MeetingLifecycleState.rescheduling) return;
  yield RecordMeetingMovedCommand(
    meetingId: input.move.meetingId,
    newSlotStart: input.move.newSlotStart,
    newSlotEnd: input.move.newSlotEnd,
  );
});
