import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RecordNewSlotVerifiedAggregate =
    EventSourcingAggregate<
      RecordNewSlotVerifiedCommand,
      RecordNewSlotVerifiedState,
      MeetingsEvent,
      NoMetadata,
      NoMetadata
    >;

RecordNewSlotVerifiedAggregate buildRecordNewSlotVerifiedAggregate({
  required RecordNewSlotVerifiedEventRepository repository,
}) => createEventSourcingAggregate(decider: recordNewSlotVerifiedDecider, eventRepository: repository);
