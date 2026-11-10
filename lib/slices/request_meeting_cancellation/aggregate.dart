import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RequestMeetingCancellationAggregate =
    EventSourcingAggregate<RequestMeetingCancellationCommand, CancellationState, DomainEvent, NoMetadata, NoMetadata>;

RequestMeetingCancellationAggregate buildRequestMeetingCancellationAggregate({
  required RequestMeetingCancellationEventRepository repository,
}) => createEventSourcingAggregate(decider: requestMeetingCancellationDecider, eventRepository: repository);
