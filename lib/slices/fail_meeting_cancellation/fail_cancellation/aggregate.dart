import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef FailCancellationAggregate =
    EventSourcingAggregate<FailCancellationCommand, FailCancellationState, MeetingsEvent, NoMetadata, NoMetadata>;

FailCancellationAggregate buildFailCancellationAggregate({required FailCancellationEventRepository repository}) =>
    createEventSourcingAggregate(decider: failCancellationDecider, eventRepository: repository);
