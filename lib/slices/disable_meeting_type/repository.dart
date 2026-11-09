import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the lifecycle history of the meeting type that a command names. The decision folds the creation (host) and the
/// lifecycle events; edits do not change either, so they are not read.
final class DisableMeetingTypeEventRepository
    extends ConsistentEventRepository<DisableMeetingTypeCommand, HostSetupEvent> {
  DisableMeetingTypeEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(DisableMeetingTypeCommand command) => [
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
