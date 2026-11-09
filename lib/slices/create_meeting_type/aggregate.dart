import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef CreateMeetingTypeAggregate =
    EventSourcingAggregate<CreateMeetingTypeCommand, CreateMeetingTypeState, HostSetupEvent, NoMetadata, NoMetadata>;

CreateMeetingTypeAggregate buildCreateMeetingTypeAggregate({required CreateMeetingTypeEventRepository repository}) =>
    createEventSourcingAggregate(decider: createMeetingTypeDecider, eventRepository: repository);
