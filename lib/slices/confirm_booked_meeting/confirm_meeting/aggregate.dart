import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef ConfirmMeetingAggregate =
    EventSourcingAggregate<ConfirmMeetingCommand, ConfirmMeetingState, MeetingsEvent, NoMetadata, NoMetadata>;

ConfirmMeetingAggregate buildConfirmMeetingAggregate({required ConfirmMeetingEventRepository repository}) =>
    createEventSourcingAggregate(decider: confirmMeetingDecider, eventRepository: repository);
