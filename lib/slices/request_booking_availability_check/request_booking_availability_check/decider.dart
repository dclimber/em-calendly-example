import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `request_booking_availability_check`.
///
/// The model gives the transition `request_booking_check` from `pending_calendar` only, and it leaves the state
/// unchanged. A repeat is refused here (see [AvailabilityCheckAlreadyRequestedError]), so the event is emitted once.
final requestBookingAvailabilityCheckDecider =
    Decider<RequestBookingAvailabilityCheckCommand, RequestBookingAvailabilityCheckState, MeetingsEvent>(
      initialState: const RequestBookingAvailabilityCheckState(),
      decide: (command, state) async* {
        if (state.lifecycle != MeetingLifecycleState.pendingCalendar) {
          throw const MeetingNotPendingCalendarError();
        }
        if (state.checkRequested) throw const AvailabilityCheckAlreadyRequestedError();
        yield BookingAvailabilityCheckRequestedEvent(
          meetingId: command.meetingId,
          hostId: command.hostId,
          slotStart: command.slotStart,
          slotEnd: command.slotEnd,
        );
      },
      evolve: (state, event) => switch (event) {
        MeetingSlotReservedEvent() => RequestBookingAvailabilityCheckState(
          lifecycle: MeetingLifecycleState.pendingCalendar,
          checkRequested: state.checkRequested,
        ),
        BookingAvailabilityCheckRequestedEvent() => RequestBookingAvailabilityCheckState(
          lifecycle: state.lifecycle,
          checkRequested: true,
        ),
        MeetingConfirmedEvent() => RequestBookingAvailabilityCheckState(
          lifecycle: MeetingLifecycleState.confirmed,
          checkRequested: state.checkRequested,
        ),
        MeetingBookingFailedEvent() => RequestBookingAvailabilityCheckState(
          lifecycle: MeetingLifecycleState.bookingFailed,
          checkRequested: state.checkRequested,
        ),
        _ => state,
      },
    );
