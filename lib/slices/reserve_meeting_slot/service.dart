import '../../bounded_contexts/employee_directory/api.dart';
import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'command.dart';
import 'errors.dart';
import 'repository.dart';

/// A booking as the booker sent it. Ids and the clock are supplied by the handler.
final class ReserveMeetingSlotInput {
  const ReserveMeetingSlotInput({
    required this.meetingId,
    required this.meetingTypeId,
    required this.bookerId,
    required this.bookerName,
    required this.bookerEmail,
    required this.slotStart,
    required this.slotEnd,
    required this.now,
  });

  final String meetingId;
  final String meetingTypeId;
  final String bookerId;
  final String bookerName;
  final String bookerEmail;
  final DateTime slotStart;
  final DateTime slotEnd;
  final DateTime now;
}

final class ReserveMeetingSlotService {
  ReserveMeetingSlotService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  static const _maxAttempts = 3;

  /// Reserves the slot. The host and the schedule come from the meeting type's current history, which is read again
  /// on every attempt, so an edit that moves the schedule is seen before the reservation is appended.
  Future<List<DomainEvent>> handle(ReserveMeetingSlotInput input) async {
    for (var attempt = 1; ; attempt++) {
      final keys = await _meetingTypeKeys(input.meetingTypeId);
      if (keys == null) throw const MeetingTypeNotAcceptingError();
      final command = ReserveMeetingSlotCommand(
        meetingId: MeetingId(input.meetingId),
        meetingTypeId: MeetingTypeId(input.meetingTypeId),
        hostId: HostId(keys.hostId),
        scheduleId: ScheduleId(keys.scheduleId),
        bookerId: BookerId(input.bookerId),
        bookerName: EmployeeName(input.bookerName),
        bookerEmail: EmployeeEmail(input.bookerEmail),
        slotStart: input.slotStart,
        slotEnd: input.slotEnd,
        now: input.now,
      );
      try {
        return await buildReserveMeetingSlotAggregate(
          repository: ReserveMeetingSlotEventRepository(_eventStore),
        ).handle(command).toList();
      } on AppendConditionFailed {
        if (attempt >= _maxAttempts) rethrow;
      }
    }
  }

  /// The host and the schedule of the meeting type, or null when the meeting type was never created.
  Future<({String hostId, String scheduleId})?> _meetingTypeKeys(String meetingTypeId) async {
    final read = await _eventStore.read([
      (
        tag: 'meetingTypeId',
        value: meetingTypeId,
        eventTypes: const [MeetingTypeCreatedEvent, MeetingTypeEditedEvent],
      ),
    ]);
    String? hostId;
    String? scheduleId;
    for (final stored in read.events) {
      final event = stored.event;
      if (event is MeetingTypeCreatedEvent) {
        hostId = event.hostId.value;
        scheduleId = event.scheduleId.value;
      } else if (event is MeetingTypeEditedEvent) {
        scheduleId = event.scheduleId.value;
      }
    }
    if (hostId == null || scheduleId == null) return null;
    return (hostId: hostId, scheduleId: scheduleId);
  }
}
