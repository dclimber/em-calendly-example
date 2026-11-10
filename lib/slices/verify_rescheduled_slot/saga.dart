import 'package:fmodel/fmodel.dart';

import 'free_answers_for_reschedules/state.dart';
import 'record_new_slot_verified/command.dart';

/// The processor `reschedule_free_translator`: each listed free answer yields one `record_new_slot_verified` command
/// for its meeting.
final rescheduleFreeTranslatorSaga = saga<FreeAnswerForRescheduleState, RecordNewSlotVerifiedCommand>(
  (item) async* {
    yield RecordNewSlotVerifiedCommand(meetingId: item.meetingId);
  },
);
