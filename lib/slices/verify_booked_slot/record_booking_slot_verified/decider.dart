import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `record_booking_slot_verified`.
///
/// The model gives the transition `verify_booked_slot` from `pending_calendar`, and it leaves the state in
/// `pending_calendar`. A repeat is refused here (see [BookingSlotAlreadyVerifiedError]), so the event is emitted once.
final recordBookingSlotVerifiedDecider =
    Decider<RecordBookingSlotVerifiedCommand, RecordBookingSlotVerifiedState, MeetingsEvent>(
      initialState: const RecordBookingSlotVerifiedState(),
      decide: (command, state) async* {
        if (state.lifecycle != MeetingLifecycleState.pendingCalendar) {
          throw const MeetingNotPendingCalendarError();
        }
        if (state.slotVerified) throw const BookingSlotAlreadyVerifiedError();
        yield BookingSlotVerifiedEvent(meetingId: command.meetingId);
      },
      evolve: (state, event) => switch (event) {
        MeetingSlotReservedEvent() => RecordBookingSlotVerifiedState(
          lifecycle: MeetingLifecycleState.pendingCalendar,
          slotVerified: state.slotVerified,
        ),
        BookingSlotVerifiedEvent() => RecordBookingSlotVerifiedState(
          lifecycle: state.lifecycle,
          slotVerified: true,
        ),
        MeetingConfirmedEvent() => RecordBookingSlotVerifiedState(
          lifecycle: MeetingLifecycleState.confirmed,
          slotVerified: state.slotVerified,
        ),
        MeetingBookingFailedEvent() => RecordBookingSlotVerifiedState(
          lifecycle: MeetingLifecycleState.bookingFailed,
          slotVerified: state.slotVerified,
        ),
        _ => state,
      },
    );
