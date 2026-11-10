import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'command.dart';
import 'errors.dart';
import 'repository.dart';

/// The form input of the reschedule. [requestedBy] is the signed-in viewer; [now] is the current time.
final class RequestMeetingRescheduleInput {
  const RequestMeetingRescheduleInput({
    required this.meetingId,
    required this.requestedBy,
    required this.newSlotStart,
    required this.newSlotEnd,
    required this.now,
  });

  final String meetingId;
  final String requestedBy;
  final DateTime newSlotStart;
  final DateTime newSlotEnd;
  final DateTime now;
}

final class RequestMeetingRescheduleService {
  RequestMeetingRescheduleService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  static const _maxAttempts = 3;

  Future<List<DomainEvent>> handle(RequestMeetingRescheduleInput input) async {
    for (var attempt = 1; ; attempt++) {
      final reserved = await _reservedOf(input.meetingId);
      // A meeting without a reservation has no participants, so nobody may reschedule it.
      if (reserved == null) throw const NotAParticipantError();
      // A meeting type is created before any of its meetings is reserved, so its schedule is always known.
      final scheduleId = await _scheduleIdOf(reserved.meetingTypeId);
      if (scheduleId == null) throw StateError('A reserved meeting has a meeting type with a schedule.');
      final command = RequestMeetingRescheduleCommand(
        meetingId: MeetingId(input.meetingId),
        hostId: HostId(reserved.hostId),
        meetingTypeId: MeetingTypeId(reserved.meetingTypeId),
        scheduleId: ScheduleId(scheduleId),
        requestedBy: RequestedBy(input.requestedBy),
        newSlotStart: input.newSlotStart,
        newSlotEnd: input.newSlotEnd,
        now: input.now,
      );
      try {
        return await buildRequestMeetingRescheduleAggregate(
          repository: RequestMeetingRescheduleEventRepository(_eventStore),
        ).handle(command).toList();
      } on AppendConditionFailed {
        if (attempt >= _maxAttempts) rethrow;
      }
    }
  }

  /// The host and meeting type of the meeting, read from its `meeting_slot_reserved`, or null when the meeting was never
  /// reserved.
  Future<({String hostId, String meetingTypeId})?> _reservedOf(String meetingId) async {
    final read = await _eventStore.read([
      (tag: 'meetingId', value: meetingId, eventTypes: const [MeetingSlotReservedEvent]),
    ]);
    for (final stored in read.events) {
      final event = stored.event;
      if (event is MeetingSlotReservedEvent) {
        return (hostId: event.hostId.value, meetingTypeId: event.meetingTypeId.value);
      }
    }
    return null;
  }

  /// The schedule of the meeting type, from its latest `meeting_type_created` or `meeting_type_edited`. A deleted meeting
  /// type keeps its schedule, so the history is read whatever its state. Null when the meeting type was never created.
  Future<String?> _scheduleIdOf(String meetingTypeId) async {
    final read = await _eventStore.read([
      (
        tag: 'meetingTypeId',
        value: meetingTypeId,
        eventTypes: const [MeetingTypeCreatedEvent, MeetingTypeEditedEvent],
      ),
    ]);
    String? scheduleId;
    for (final stored in read.events) {
      final event = stored.event;
      if (event is MeetingTypeCreatedEvent) {
        scheduleId = event.scheduleId.value;
      } else if (event is MeetingTypeEditedEvent) {
        scheduleId = event.scheduleId.value;
      }
    }
    return scheduleId;
  }
}
