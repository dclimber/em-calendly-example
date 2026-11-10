import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef RecordMeetingDeletedAggregate =
    EventSourcingAggregate<
      RecordMeetingDeletedCommand,
      RecordMeetingDeletedState,
      MeetingsEvent,
      NoMetadata,
      NoMetadata
    >;

RecordMeetingDeletedAggregate buildRecordMeetingDeletedAggregate({
  required RecordMeetingDeletedEventRepository repository,
}) => createEventSourcingAggregate(decider: recordMeetingDeletedDecider, eventRepository: repository);
