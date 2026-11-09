import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the history of the meeting type that a command creates, and the availability schedule that it names.
final class CreateMeetingTypeEventRepository
    extends ConsistentEventRepository<CreateMeetingTypeCommand, HostSetupEvent> {
  CreateMeetingTypeEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(CreateMeetingTypeCommand command) => [
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
    (
      tag: 'scheduleId',
      value: command.scheduleId.value,
      eventTypes: const [AvailabilityScheduleCreatedEvent],
    ),
  ];
}
