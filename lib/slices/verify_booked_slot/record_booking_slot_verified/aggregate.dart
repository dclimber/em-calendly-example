import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RecordBookingSlotVerifiedAggregate =
    EventSourcingAggregate<
      RecordBookingSlotVerifiedCommand,
      RecordBookingSlotVerifiedState,
      MeetingsEvent,
      NoMetadata,
      NoMetadata
    >;

RecordBookingSlotVerifiedAggregate buildRecordBookingSlotVerifiedAggregate({
  required RecordBookingSlotVerifiedEventRepository repository,
}) => createEventSourcingAggregate(decider: recordBookingSlotVerifiedDecider, eventRepository: repository);
