import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef CompleteCancellationAggregate =
    EventSourcingAggregate<
      CompleteCancellationCommand,
      CompleteCancellationState,
      MeetingsEvent,
      NoMetadata,
      NoMetadata
    >;

CompleteCancellationAggregate buildCompleteCancellationAggregate({
  required CompleteCancellationEventRepository repository,
}) => createEventSourcingAggregate(decider: completeCancellationDecider, eventRepository: repository);
