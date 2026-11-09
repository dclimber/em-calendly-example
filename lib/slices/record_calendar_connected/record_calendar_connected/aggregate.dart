import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RecordCalendarConnectedAggregate =
    EventSourcingAggregate<
      RecordCalendarConnectedCommand,
      RecordCalendarConnectedState,
      HostSetupEvent,
      NoMetadata,
      NoMetadata
    >;

RecordCalendarConnectedAggregate buildRecordCalendarConnectedAggregate({
  required RecordCalendarConnectedEventRepository repository,
}) => createEventSourcingAggregate(decider: recordCalendarConnectedDecider, eventRepository: repository);
