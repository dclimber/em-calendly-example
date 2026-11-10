import 'package:fmodel/fmodel.dart';

import 'confirmations_to_send/state.dart';
import 'send_booking_confirmation/command.dart';

/// The processor `confirmation_sender`: each ready item yields one `send_booking_confirmation` command for its meeting.
/// An item that is not confirmed yet yields nothing.
final confirmationSenderSaga = saga<ConfirmationToSendState, SendBookingConfirmationCommand>((item) async* {
  if (!item.ready) return;
  yield SendBookingConfirmationCommand(meetingId: item.meetingId, participants: item.participants);
});
