import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the lifecycle history of the meeting type that a command names. The decision folds the creation (host) and the
/// lifecycle events; edits do not change either, so they are not read. Meetings are not read: they remain on delete.
final class DeleteMeetingTypeEventRepository
    extends ConsistentEventRepository<DeleteMeetingTypeCommand, HostSetupEvent> {
  DeleteMeetingTypeEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(DeleteMeetingTypeCommand command) => [
    (
      tag: 'meetingTypeId',
      value: command.meetingTypeId.value,
      eventTypes: const [
        MeetingTypeCreatedEvent,
        MeetingTypeDisabledEvent,
        MeetingTypeEnabledEvent,
        MeetingTypeDeletedEvent,
      ],
    ),
  ];
}
