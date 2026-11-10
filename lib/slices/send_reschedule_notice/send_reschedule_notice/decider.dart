import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `send_reschedule_notice`.
///
/// The model gives the transition `send_reschedule_notice` from `confirmed` only, and it leaves the state `confirmed`.
/// A repeat for the same new time is refused (see [RescheduleNoticeAlreadySentError]), so one new time gets one event.
/// A later, different reschedule has another new time and gets its own notice.
final sendRescheduleNoticeDecider = Decider<SendRescheduleNoticeCommand, SendRescheduleNoticeState, MeetingsEvent>(
  initialState: const SendRescheduleNoticeState(),
  decide: (command, state) async* {
    if (state.lifecycle != MeetingLifecycleState.confirmed) throw const MeetingNotConfirmedForNoticeError();
    if (state.lastNoticedNewSlotStart == command.newSlotStart) throw const RescheduleNoticeAlreadySentError();
    yield RescheduleNoticeSentEvent(
      meetingId: command.meetingId,
      newSlotStart: command.newSlotStart,
      participants: command.participants,
    );
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
    RescheduleNoticeSentEvent() => SendRescheduleNoticeState(
      lifecycle: state.lifecycle,
      lastNoticedNewSlotStart: event.newSlotStart,
    ),
    _ => state,
  },
);

SendRescheduleNoticeState _inLifecycle(SendRescheduleNoticeState state, MeetingLifecycleState lifecycle) =>
    SendRescheduleNoticeState(lifecycle: lifecycle, lastNoticedNewSlotStart: state.lastNoticedNewSlotStart);
