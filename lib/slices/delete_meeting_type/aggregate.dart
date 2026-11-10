import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef DeleteMeetingTypeAggregate =
    EventSourcingAggregate<DeleteMeetingTypeCommand, DeleteMeetingTypeState, HostSetupEvent, NoMetadata, NoMetadata>;

DeleteMeetingTypeAggregate buildDeleteMeetingTypeAggregate({required DeleteMeetingTypeEventRepository repository}) =>
    createEventSourcingAggregate(decider: deleteMeetingTypeDecider, eventRepository: repository);
