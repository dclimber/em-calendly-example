import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RecordConnectionFailureAggregate =
    EventSourcingAggregate<
      RecordConnectionFailureCommand,
      RecordConnectionFailureState,
      HostSetupEvent,
      NoMetadata,
      NoMetadata
    >;

RecordConnectionFailureAggregate buildRecordConnectionFailureAggregate({
  required RecordConnectionFailureEventRepository repository,
}) => createEventSourcingAggregate(decider: recordConnectionFailureDecider, eventRepository: repository);
