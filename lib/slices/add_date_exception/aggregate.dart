import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef AddDateExceptionAggregate =
    EventSourcingAggregate<AddDateExceptionCommand, AddDateExceptionState, HostSetupEvent, NoMetadata, NoMetadata>;

AddDateExceptionAggregate buildAddDateExceptionAggregate({required AddDateExceptionEventRepository repository}) =>
    createEventSourcingAggregate(decider: addDateExceptionDecider, eventRepository: repository);
