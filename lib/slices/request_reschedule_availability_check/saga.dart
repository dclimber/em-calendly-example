import 'package:fmodel/fmodel.dart';

import 'request_reschedule_availability_check/command.dart';
import 'reschedules_awaiting_live_check/state.dart';

/// The processor `reschedule_check_requester`: each requested new time that awaits a live check yields one
/// `request_reschedule_availability_check` command for its meeting, host, and new slot.
final rescheduleCheckRequesterSaga = saga<RescheduleAwaitingLiveCheckState, RequestRescheduleAvailabilityCheckCommand>(
  (item) async* {
    yield RequestRescheduleAvailabilityCheckCommand(
      meetingId: item.meetingId,
      hostId: item.hostId,
      newSlotStart: item.newSlotStart,
      newSlotEnd: item.newSlotEnd,
    );
  },
);
