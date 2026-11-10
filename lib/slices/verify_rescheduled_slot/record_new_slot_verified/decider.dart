import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `record_new_slot_verified`.
///
/// The model gives the transition `verify_new_slot` from `rescheduling` only, and it leaves the state in
/// `rescheduling`. A repeat for the current reschedule request is refused here (see [NewSlotAlreadyVerifiedError]),
/// so the event is emitted once per reschedule request.
final recordNewSlotVerifiedDecider = Decider<RecordNewSlotVerifiedCommand, RecordNewSlotVerifiedState, MeetingsEvent>(
  initialState: const RecordNewSlotVerifiedState(),
  decide: (command, state) async* {
    if (state.lifecycle != MeetingLifecycleState.rescheduling) throw const MeetingNotReschedulingError();
    if (state.newSlotVerified) throw const NewSlotAlreadyVerifiedError();
    yield NewSlotVerifiedEvent(meetingId: command.meetingId);
  },
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => RecordNewSlotVerifiedState(
      lifecycle: MeetingLifecycleState.pendingCalendar,
      newSlotVerified: state.newSlotVerified,
    ),
    MeetingConfirmedEvent() => RecordNewSlotVerifiedState(
      lifecycle: MeetingLifecycleState.confirmed,
      newSlotVerified: state.newSlotVerified,
    ),
    MeetingBookingFailedEvent() => RecordNewSlotVerifiedState(
      lifecycle: MeetingLifecycleState.bookingFailed,
      newSlotVerified: state.newSlotVerified,
    ),
    MeetingRescheduleRequestedEvent() => const RecordNewSlotVerifiedState(
      lifecycle: MeetingLifecycleState.rescheduling,
    ),
    NewSlotVerifiedEvent() => RecordNewSlotVerifiedState(
      lifecycle: state.lifecycle,
      newSlotVerified: true,
    ),
    MeetingRescheduledEvent() ||
    MeetingRescheduleFailedEvent() ||
    MeetingMovedInCalendarEvent() => RecordNewSlotVerifiedState(
      lifecycle: MeetingLifecycleState.confirmed,
      newSlotVerified: state.newSlotVerified,
    ),
    MeetingCancellationRequestedEvent() => RecordNewSlotVerifiedState(
      lifecycle: MeetingLifecycleState.canceling,
      newSlotVerified: state.newSlotVerified,
    ),
    MeetingCanceledEvent() => RecordNewSlotVerifiedState(
      lifecycle: MeetingLifecycleState.canceled,
      newSlotVerified: state.newSlotVerified,
    ),
    MeetingCompletedEvent() => RecordNewSlotVerifiedState(
      lifecycle: MeetingLifecycleState.completed,
      newSlotVerified: state.newSlotVerified,
    ),
    _ => state,
  },
);
