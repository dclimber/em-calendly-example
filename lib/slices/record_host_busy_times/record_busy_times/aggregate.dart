import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RecordBusyTimesAggregate =
    EventSourcingAggregate<RecordBusyTimesCommand, RecordBusyTimesState, HostSetupEvent, NoMetadata, NoMetadata>;

RecordBusyTimesAggregate buildRecordBusyTimesAggregate({required RecordBusyTimesEventRepository repository}) =>
    createEventSourcingAggregate(decider: recordBusyTimesDecider, eventRepository: repository);
