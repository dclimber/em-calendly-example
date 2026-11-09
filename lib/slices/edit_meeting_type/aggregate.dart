import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef EditMeetingTypeAggregate =
    EventSourcingAggregate<EditMeetingTypeCommand, EditMeetingTypeState, HostSetupEvent, NoMetadata, NoMetadata>;

EditMeetingTypeAggregate buildEditMeetingTypeAggregate({required EditMeetingTypeEventRepository repository}) =>
    createEventSourcingAggregate(decider: editMeetingTypeDecider, eventRepository: repository);
