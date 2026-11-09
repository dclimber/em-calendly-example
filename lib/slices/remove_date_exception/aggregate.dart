import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RemoveDateExceptionAggregate =
    EventSourcingAggregate<
      RemoveDateExceptionCommand,
      RemoveDateExceptionState,
      HostSetupEvent,
      NoMetadata,
      NoMetadata
    >;

RemoveDateExceptionAggregate buildRemoveDateExceptionAggregate({
  required RemoveDateExceptionEventRepository repository,
}) => createEventSourcingAggregate(decider: removeDateExceptionDecider, eventRepository: repository);
