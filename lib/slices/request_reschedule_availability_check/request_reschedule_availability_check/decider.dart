import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `request_reschedule_availability_check`.
///
/// The model gives the transition `request_reschedule_check` from `rescheduling` only, and it leaves the state
/// unchanged. A repeat for the same new slot is refused here (see [RescheduleAvailabilityCheckAlreadyRequestedError]),
/// so the event is emitted once per requested new time, also when the request is delivered again.
final requestRescheduleAvailabilityCheckDecider =
    Decider<RequestRescheduleAvailabilityCheckCommand, RequestRescheduleAvailabilityCheckState, MeetingsEvent>(
      initialState: const RequestRescheduleAvailabilityCheckState(),
      decide: (command, state) async* {
        if (state.lifecycle != MeetingLifecycleState.rescheduling) throw const MeetingNotReschedulingError();
        final checked = state.checkedSlot;
        if (checked != null && checked.start == command.newSlotStart && checked.end == command.newSlotEnd) {
          throw const RescheduleAvailabilityCheckAlreadyRequestedError();
        }
        yield RescheduleAvailabilityCheckRequestedEvent(
          meetingId: command.meetingId,
          hostId: command.hostId,
          newSlotStart: command.newSlotStart,
          newSlotEnd: command.newSlotEnd,
        );
      },
      evolve: (state, event) => switch (event) {
        MeetingSlotReservedEvent() => RequestRescheduleAvailabilityCheckState(
          lifecycle: MeetingLifecycleState.pendingCalendar,
          checkedSlot: state.checkedSlot,
        ),
        MeetingConfirmedEvent() => RequestRescheduleAvailabilityCheckState(
          lifecycle: MeetingLifecycleState.confirmed,
          checkedSlot: state.checkedSlot,
        ),
        MeetingBookingFailedEvent() => RequestRescheduleAvailabilityCheckState(
          lifecycle: MeetingLifecycleState.bookingFailed,
          checkedSlot: state.checkedSlot,
        ),
        MeetingRescheduleRequestedEvent() => RequestRescheduleAvailabilityCheckState(
          lifecycle: MeetingLifecycleState.rescheduling,
          checkedSlot: state.checkedSlot,
        ),
        RescheduleAvailabilityCheckRequestedEvent() => RequestRescheduleAvailabilityCheckState(
          lifecycle: state.lifecycle,
          checkedSlot: (start: event.newSlotStart, end: event.newSlotEnd),
        ),
        MeetingRescheduledEvent() ||
        MeetingRescheduleFailedEvent() ||
        MeetingMovedInCalendarEvent() => RequestRescheduleAvailabilityCheckState(
          lifecycle: MeetingLifecycleState.confirmed,
          checkedSlot: state.checkedSlot,
        ),
        MeetingCancellationRequestedEvent() => RequestRescheduleAvailabilityCheckState(
          lifecycle: MeetingLifecycleState.canceling,
          checkedSlot: state.checkedSlot,
        ),
        MeetingCanceledEvent() => RequestRescheduleAvailabilityCheckState(
          lifecycle: MeetingLifecycleState.canceled,
          checkedSlot: state.checkedSlot,
        ),
        MeetingCompletedEvent() => RequestRescheduleAvailabilityCheckState(
          lifecycle: MeetingLifecycleState.completed,
          checkedSlot: state.checkedSlot,
        ),
        _ => state,
      },
    );
