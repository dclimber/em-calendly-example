import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef CreateAvailabilityScheduleAggregate =
    EventSourcingAggregate<
      CreateAvailabilityScheduleCommand,
      CreateAvailabilityScheduleState,
      HostSetupEvent,
      NoMetadata,
      NoMetadata
    >;

CreateAvailabilityScheduleAggregate buildCreateAvailabilityScheduleAggregate({
  required CreateAvailabilityScheduleEventRepository repository,
}) => createEventSourcingAggregate(decider: createAvailabilityScheduleDecider, eventRepository: repository);
