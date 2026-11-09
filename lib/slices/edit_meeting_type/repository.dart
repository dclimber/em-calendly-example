import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the lifecycle history of the meeting type that a command names. Only `host_setup` events are read; booked
/// meetings are not part of the decision.
final class EditMeetingTypeEventRepository extends ConsistentEventRepository<EditMeetingTypeCommand, HostSetupEvent> {
  EditMeetingTypeEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(EditMeetingTypeCommand command) => [
    (
      tag: 'meetingTypeId',
      value: command.meetingTypeId.value,
      eventTypes: const [
        MeetingTypeCreatedEvent,
        MeetingTypeEditedEvent,
        MeetingTypeDisabledEvent,
        MeetingTypeEnabledEvent,
        MeetingTypeDeletedEvent,
      ],
    ),
  ];
}
