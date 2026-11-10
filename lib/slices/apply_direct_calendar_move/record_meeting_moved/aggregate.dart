import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RecordMeetingMovedAggregate =
    EventSourcingAggregate<RecordMeetingMovedCommand, RecordMeetingMovedState, MeetingsEvent, NoMetadata, NoMetadata>;

RecordMeetingMovedAggregate buildRecordMeetingMovedAggregate({required RecordMeetingMovedEventRepository repository}) =>
    createEventSourcingAggregate(decider: recordMeetingMovedDecider, eventRepository: repository);
