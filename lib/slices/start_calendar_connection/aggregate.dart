import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef StartCalendarConnectionAggregate =
    EventSourcingAggregate<
      StartCalendarConnectionCommand,
      StartCalendarConnectionState,
      HostSetupEvent,
      NoMetadata,
      NoMetadata
    >;

StartCalendarConnectionAggregate buildStartCalendarConnectionAggregate({
  required StartCalendarConnectionEventRepository repository,
}) => createEventSourcingAggregate(decider: startCalendarConnectionDecider, eventRepository: repository);
