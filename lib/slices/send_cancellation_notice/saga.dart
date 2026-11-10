import 'package:fmodel/fmodel.dart';

import 'cancellation_notices_to_send/state.dart';
import 'send_cancellation_notice/command.dart';

/// The processor `cancellation_notifier`: each ready item yields one `send_cancellation_notice` command. An item that is
/// not ready yields nothing.
final cancellationNotifierSaga = saga<CancellationNoticeToSendState, SendCancellationNoticeCommand>((item) async* {
  if (!item.ready) return;
  yield SendCancellationNoticeCommand(meetingId: item.meetingId, participants: item.participants);
});
