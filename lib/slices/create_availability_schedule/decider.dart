import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'state.dart';

/// The decider of the `availability_schedule` aggregate for `create_availability_schedule`.
///
/// The `create` transition starts the stream (`before = []`). The model states no invalid transition and no scenario
/// for this command on an existing stream, so the decider accepts the command in every state (a lifecycle gap).
final createAvailabilityScheduleDecider =
    Decider<CreateAvailabilityScheduleCommand, CreateAvailabilityScheduleState, HostSetupEvent>(
      initialState: const CreateAvailabilityScheduleState(),
      decide: (command, state) async* {
        yield AvailabilityScheduleCreatedEvent(
          scheduleId: command.scheduleId,
          hostId: command.hostId,
          scheduleName: command.scheduleName,
          timeZone: command.timeZone,
        );
      },
      evolve: (state, event) => switch (event) {
        AvailabilityScheduleCreatedEvent() => const CreateAvailabilityScheduleState(
          lifecycle: AvailabilityScheduleLifecycleState.defined,
        ),
        WeeklyHoursSetEvent() ||
        DateExceptionAddedEvent() ||
        DateExceptionChangedEvent() ||
        DateExceptionRemovedEvent() ||
        BookingLimitsSetEvent() => const CreateAvailabilityScheduleState(
          lifecycle: AvailabilityScheduleLifecycleState.defined,
        ),
        _ => state,
      },
    );
