import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef SendRescheduleNoticeAggregate =
    EventSourcingAggregate<
      SendRescheduleNoticeCommand,
      SendRescheduleNoticeState,
      MeetingsEvent,
      NoMetadata,
      NoMetadata
    >;

SendRescheduleNoticeAggregate buildSendRescheduleNoticeAggregate({
  required SendRescheduleNoticeEventRepository repository,
}) => createEventSourcingAggregate(decider: sendRescheduleNoticeDecider, eventRepository: repository);
