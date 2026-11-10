import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef EnableMeetingTypeAggregate =
    EventSourcingAggregate<EnableMeetingTypeCommand, EnableMeetingTypeState, HostSetupEvent, NoMetadata, NoMetadata>;

EnableMeetingTypeAggregate buildEnableMeetingTypeAggregate({required EnableMeetingTypeEventRepository repository}) =>
    createEventSourcingAggregate(decider: enableMeetingTypeDecider, eventRepository: repository);
