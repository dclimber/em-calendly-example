import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `send_cancellation_notice`.
///
/// The model gives the transition `send_cancellation_notice` from `canceled` only, and it leaves the state `canceled`.
/// A repeat is refused (see [CancellationNoticeAlreadySentError]), so one meeting gets one `cancellation_notice_sent`.
final sendCancellationNoticeDecider =
    Decider<SendCancellationNoticeCommand, SendCancellationNoticeState, MeetingsEvent>(
      initialState: const SendCancellationNoticeState(),
      decide: (command, state) async* {
        if (state.lifecycle != MeetingLifecycleState.canceled) throw const MeetingNotCanceledForNoticeError();
        if (state.noticeSent) throw const CancellationNoticeAlreadySentError();
        yield CancellationNoticeSentEvent(meetingId: command.meetingId, participants: command.participants);
      },
      evolve: (state, event) => switch (event) {
        MeetingSlotReservedEvent() => _inLifecycle(state, MeetingLifecycleState.pendingCalendar),
        MeetingConfirmedEvent() => _inLifecycle(state, MeetingLifecycleState.confirmed),
        MeetingBookingFailedEvent() => _inLifecycle(state, MeetingLifecycleState.bookingFailed),
        MeetingRescheduleRequestedEvent() => _inLifecycle(state, MeetingLifecycleState.rescheduling),
        MeetingRescheduledEvent() => _inLifecycle(state, MeetingLifecycleState.confirmed),
        MeetingRescheduleFailedEvent() => _inLifecycle(state, MeetingLifecycleState.confirmed),
        MeetingMovedInCalendarEvent() => _inLifecycle(state, MeetingLifecycleState.confirmed),
        MeetingCancellationRequestedEvent() => _inLifecycle(state, MeetingLifecycleState.canceling),
        MeetingCancellationFailedEvent() => _inLifecycle(state, MeetingLifecycleState.confirmed),
        MeetingCanceledEvent() => _inLifecycle(state, MeetingLifecycleState.canceled),
        MeetingCompletedEvent() => _inLifecycle(state, MeetingLifecycleState.completed),
        CancellationNoticeSentEvent() => SendCancellationNoticeState(lifecycle: state.lifecycle, noticeSent: true),
        _ => state,
      },
    );

SendCancellationNoticeState _inLifecycle(SendCancellationNoticeState state, MeetingLifecycleState lifecycle) =>
    SendCancellationNoticeState(lifecycle: lifecycle, noticeSent: state.noticeSent);
