import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RequestBookingAvailabilityCheckAggregate =
    EventSourcingAggregate<
      RequestBookingAvailabilityCheckCommand,
      RequestBookingAvailabilityCheckState,
      MeetingsEvent,
      NoMetadata,
      NoMetadata
    >;

RequestBookingAvailabilityCheckAggregate buildRequestBookingAvailabilityCheckAggregate({
  required RequestBookingAvailabilityCheckEventRepository repository,
}) => createEventSourcingAggregate(decider: requestBookingAvailabilityCheckDecider, eventRepository: repository);
