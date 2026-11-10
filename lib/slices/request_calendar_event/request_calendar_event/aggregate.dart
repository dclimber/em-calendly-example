import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RequestCalendarEventAggregate =
    EventSourcingAggregate<
      RequestCalendarEventCommand,
      RequestCalendarEventState,
      MeetingsEvent,
      NoMetadata,
      NoMetadata
    >;

RequestCalendarEventAggregate buildRequestCalendarEventAggregate({
  required RequestCalendarEventEventRepository repository,
}) => createEventSourcingAggregate(decider: requestCalendarEventDecider, eventRepository: repository);
