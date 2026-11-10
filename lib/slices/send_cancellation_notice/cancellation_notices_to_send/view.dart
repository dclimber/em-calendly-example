import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `cancellation_notices_to_send`. A reservation records the title, the slot, and the participants.
/// `meeting_cancellation_requested` refreshes the participants. `meeting_canceled` makes the item ready, and
/// `cancellation_notice_sent` clears the ready flag. An event for a meeting without a reservation changes nothing:
/// every meeting is reserved before it can be canceled.
final cancellationNoticesToSendView = View<CancellationNoticeToSendState?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() =>
      state == null
          ? CancellationNoticeToSendState(
              meetingId: event.meetingId,
              meetingTitle: event.meetingTitle,
              slotStart: event.slotStart,
              slotEnd: event.slotEnd,
              participants: event.participants,
            )
          : state.copyWith(participants: event.participants),
    MeetingCancellationRequestedEvent() => state?.copyWith(participants: event.participants),
    MeetingCanceledEvent() => state?.copyWith(ready: true),
    CancellationNoticeSentEvent() => state?.copyWith(ready: false),
    _ => state,
  },
);
