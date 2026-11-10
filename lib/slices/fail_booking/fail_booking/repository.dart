import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the `meeting` events that move the lifecycle into or out of `pending_calendar`, and appends the failure only if
/// none of them changed. Only those three types matter: `pending_calendar` is entered by the reservation alone.
final class FailBookingEventRepository extends ConsistentEventRepository<FailBookingCommand, MeetingsEvent> {
  FailBookingEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(FailBookingCommand command) => [
    (
      tag: 'meetingId',
      value: command.meetingId.value,
      eventTypes: const [MeetingSlotReservedEvent, MeetingConfirmedEvent, MeetingBookingFailedEvent],
    ),
  ];
}
