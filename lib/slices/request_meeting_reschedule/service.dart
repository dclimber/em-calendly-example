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
      final hostId = await _hostOf(input.meetingId);
      // A meeting without a reservation has no participants, so nobody may reschedule it.
      if (hostId == null) throw const NotAParticipantError();
      final command = RequestMeetingRescheduleCommand(
        meetingId: MeetingId(input.meetingId),
        hostId: HostId(hostId),
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

  /// The host of the meeting, read from its `meeting_slot_reserved`, or null when the meeting was never reserved.
  Future<String?> _hostOf(String meetingId) async {
    final read = await _eventStore.read([
      (tag: 'meetingId', value: meetingId, eventTypes: const [MeetingSlotReservedEvent]),
    ]);
    for (final stored in read.events) {
      final event = stored.event;
      if (event is MeetingSlotReservedEvent) return event.hostId.value;
    }
    return null;
  }
}
