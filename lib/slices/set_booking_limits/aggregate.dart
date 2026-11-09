import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef SetBookingLimitsAggregate =
    EventSourcingAggregate<SetBookingLimitsCommand, SetBookingLimitsState, HostSetupEvent, NoMetadata, NoMetadata>;

SetBookingLimitsAggregate buildSetBookingLimitsAggregate({required SetBookingLimitsEventRepository repository}) =>
    createEventSourcingAggregate(decider: setBookingLimitsDecider, eventRepository: repository);
