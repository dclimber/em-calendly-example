import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef SetWeeklyHoursAggregate =
    EventSourcingAggregate<SetWeeklyHoursCommand, SetWeeklyHoursState, HostSetupEvent, NoMetadata, NoMetadata>;

SetWeeklyHoursAggregate buildSetWeeklyHoursAggregate({required SetWeeklyHoursEventRepository repository}) =>
    createEventSourcingAggregate(decider: setWeeklyHoursDecider, eventRepository: repository);
