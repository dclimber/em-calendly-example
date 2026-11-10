import '../../platform/time/clock.dart';
import 'complete_meeting/command.dart';
import 'complete_meeting/errors.dart';
import 'complete_meeting/service.dart';
import 'meetings_to_complete/repository.dart';

/// One run of the worker `complete_finished_meeting`: every confirmed item whose end is not after [clock]'s now gets a
/// `complete_meeting` command. There is no grace period.
///
/// A refused command is ignored: the meeting left `confirmed` after the list was read, so there is nothing to complete.
Future<void> completeFinishedMeetings({
  required MeetingsToCompleteRepository repository,
  required CompleteMeetingService service,
  required Clock clock,
}) async {
  final now = clock.now();
  final due = (await repository.findWhere()).where((item) => item.confirmed && !item.slotEnd.value.isAfter(now));
  for (final item in due) {
    try {
      await service.handle(CompleteMeetingCommand(meetingId: item.meetingId));
    } on CompleteMeetingError {
      // The meeting is no longer confirmed: nothing to complete.
    }
  }
}
