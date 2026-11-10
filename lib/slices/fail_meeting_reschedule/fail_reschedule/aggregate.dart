import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef FailRescheduleAggregate =
    EventSourcingAggregate<FailRescheduleCommand, FailRescheduleState, MeetingsEvent, NoMetadata, NoMetadata>;

FailRescheduleAggregate buildFailRescheduleAggregate({required FailRescheduleEventRepository repository}) =>
    createEventSourcingAggregate(decider: failRescheduleDecider, eventRepository: repository);
