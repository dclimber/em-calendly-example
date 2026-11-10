import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RequestRescheduleAvailabilityCheckAggregate =
    EventSourcingAggregate<
      RequestRescheduleAvailabilityCheckCommand,
      RequestRescheduleAvailabilityCheckState,
      MeetingsEvent,
      NoMetadata,
      NoMetadata
    >;

RequestRescheduleAvailabilityCheckAggregate buildRequestRescheduleAvailabilityCheckAggregate({
  required RequestRescheduleAvailabilityCheckEventRepository repository,
}) => createEventSourcingAggregate(decider: requestRescheduleAvailabilityCheckDecider, eventRepository: repository);
