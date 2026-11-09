import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef DisableMeetingTypeAggregate =
    EventSourcingAggregate<DisableMeetingTypeCommand, DisableMeetingTypeState, HostSetupEvent, NoMetadata, NoMetadata>;

DisableMeetingTypeAggregate buildDisableMeetingTypeAggregate({required DisableMeetingTypeEventRepository repository}) =>
    createEventSourcingAggregate(decider: disableMeetingTypeDecider, eventRepository: repository);
