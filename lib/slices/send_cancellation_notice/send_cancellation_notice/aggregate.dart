import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef SendCancellationNoticeAggregate =
    EventSourcingAggregate<
      SendCancellationNoticeCommand,
      SendCancellationNoticeState,
      MeetingsEvent,
      NoMetadata,
      NoMetadata
    >;

SendCancellationNoticeAggregate buildSendCancellationNoticeAggregate({
  required SendCancellationNoticeEventRepository repository,
}) => createEventSourcingAggregate(decider: sendCancellationNoticeDecider, eventRepository: repository);
