import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef FailBookingAggregate =
    EventSourcingAggregate<FailBookingCommand, FailBookingState, MeetingsEvent, NoMetadata, NoMetadata>;

FailBookingAggregate buildFailBookingAggregate({required FailBookingEventRepository repository}) =>
    createEventSourcingAggregate(decider: failBookingDecider, eventRepository: repository);
