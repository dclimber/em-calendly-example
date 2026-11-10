import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef CompleteRescheduleAggregate =
    EventSourcingAggregate<CompleteRescheduleCommand, CompleteRescheduleState, MeetingsEvent, NoMetadata, NoMetadata>;

CompleteRescheduleAggregate buildCompleteRescheduleAggregate({required CompleteRescheduleEventRepository repository}) =>
    createEventSourcingAggregate(decider: completeRescheduleDecider, eventRepository: repository);
