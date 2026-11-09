import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef ChangeDateExceptionAggregate =
    EventSourcingAggregate<
      ChangeDateExceptionCommand,
      ChangeDateExceptionState,
      HostSetupEvent,
      NoMetadata,
      NoMetadata
    >;

ChangeDateExceptionAggregate buildChangeDateExceptionAggregate({
  required ChangeDateExceptionEventRepository repository,
}) => createEventSourcingAggregate(decider: changeDateExceptionDecider, eventRepository: repository);
