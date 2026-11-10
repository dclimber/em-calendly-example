import 'package:fmodel/fmodel.dart';

import 'reschedule_notices_to_send/state.dart';
import 'send_reschedule_notice/command.dart';

/// The processor `reschedule_notifier`: each ready item yields one `send_reschedule_notice` command for its new slot.
/// An item that is not ready yields nothing.
final rescheduleNotifierSaga = saga<RescheduleNoticeToSendState, SendRescheduleNoticeCommand>((item) async* {
  if (!item.ready) return;
  yield SendRescheduleNoticeCommand(
    meetingId: item.meetingId,
    newSlotStart: item.newSlotStart,
    participants: item.participants,
  );
});
