import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/event_contract.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef ReserveMeetingSlotAggregate =
    EventSourcingAggregate<ReserveMeetingSlotCommand, ReserveMeetingSlotState, DomainEvent, NoMetadata, NoMetadata>;

ReserveMeetingSlotAggregate buildReserveMeetingSlotAggregate({required ReserveMeetingSlotEventRepository repository}) =>
    createEventSourcingAggregate(decider: reserveMeetingSlotDecider, eventRepository: repository);
