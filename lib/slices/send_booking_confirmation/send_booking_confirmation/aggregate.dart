import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef SendBookingConfirmationAggregate =
    EventSourcingAggregate<
      SendBookingConfirmationCommand,
      SendBookingConfirmationState,
      MeetingsEvent,
      NoMetadata,
      NoMetadata
    >;

SendBookingConfirmationAggregate buildSendBookingConfirmationAggregate({
  required SendBookingConfirmationEventRepository repository,
}) => createEventSourcingAggregate(decider: sendBookingConfirmationDecider, eventRepository: repository);
