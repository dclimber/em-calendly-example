import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RequestCalendarEventDeletionAggregate =
    EventSourcingAggregate<
      RequestCalendarEventDeletionCommand,
      RequestCalendarEventDeletionState,
      MeetingsEvent,
      NoMetadata,
      NoMetadata
    >;

RequestCalendarEventDeletionAggregate buildRequestCalendarEventDeletionAggregate({
  required RequestCalendarEventDeletionEventRepository repository,
}) => createEventSourcingAggregate(decider: requestCalendarEventDeletionDecider, eventRepository: repository);
