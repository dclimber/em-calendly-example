import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RequestCalendarEventUpdateAggregate =
    EventSourcingAggregate<
      RequestCalendarEventUpdateCommand,
      RequestCalendarEventUpdateState,
      MeetingsEvent,
      NoMetadata,
      NoMetadata
    >;

RequestCalendarEventUpdateAggregate buildRequestCalendarEventUpdateAggregate({
  required RequestCalendarEventUpdateEventRepository repository,
}) => createEventSourcingAggregate(decider: requestCalendarEventUpdateDecider, eventRepository: repository);
