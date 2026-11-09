import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `availability_schedule` aggregate for `set_booking_limits`.
///
/// The lifecycle transition requires `defined`, so a schedule that was never created is refused. The model states no
/// rule for a caller who is not the host; the decider refuses that too.
final setBookingLimitsDecider = Decider<SetBookingLimitsCommand, SetBookingLimitsState, HostSetupEvent>(
  initialState: const SetBookingLimitsState(),
  decide: (command, state) async* {
    if (state.lifecycle != AvailabilityScheduleLifecycleState.defined) throw const ScheduleNotDefinedError();
    if (state.hostId != command.hostId) throw const NotScheduleHostError();
    yield BookingLimitsSetEvent(
      scheduleId: command.scheduleId,
      bookingWindowDays: command.bookingWindowDays,
      minimumNoticeMinutes: command.minimumNoticeMinutes,
      bufferBeforeMinutes: command.bufferBeforeMinutes,
      bufferAfterMinutes: command.bufferAfterMinutes,
    );
  },
  evolve: (state, event) => switch (event) {
    AvailabilityScheduleCreatedEvent() => SetBookingLimitsState(
      lifecycle: AvailabilityScheduleLifecycleState.defined,
      hostId: event.hostId,
    ),
    _ => state,
  },
);
