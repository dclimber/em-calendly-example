import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef CompleteMeetingAggregate =
    EventSourcingAggregate<CompleteMeetingCommand, CompleteMeetingState, MeetingsEvent, NoMetadata, NoMetadata>;

CompleteMeetingAggregate buildCompleteMeetingAggregate({required CompleteMeetingEventRepository repository}) =>
    createEventSourcingAggregate(decider: completeMeetingDecider, eventRepository: repository);
