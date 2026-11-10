import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/event_contract.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RequestMeetingRescheduleAggregate =
    EventSourcingAggregate<RequestMeetingRescheduleCommand, RescheduleState, DomainEvent, NoMetadata, NoMetadata>;

RequestMeetingRescheduleAggregate buildRequestMeetingRescheduleAggregate({
  required RequestMeetingRescheduleEventRepository repository,
}) => createEventSourcingAggregate(decider: requestMeetingRescheduleDecider, eventRepository: repository);
