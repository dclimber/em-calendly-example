import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/event_store.dart';

/// The values of a meeting type as the latest `meeting_type_created` or `meeting_type_edited` set them, with its host.
final class MeetingTypeDetails {
  const MeetingTypeDetails({
    required this.hostId,
    required this.meetingTitle,
    required this.durationMinutes,
    required this.meetingLocation,
    required this.scheduleId,
    this.meetingDescription,
  });

  final HostId hostId;
  final MeetingTitle meetingTitle;
  final DurationMinutes durationMinutes;
  final MeetingLocation meetingLocation;
  final ScheduleId scheduleId;
  final MeetingDescription? meetingDescription;
}

/// Reads the latest details of [meetingTypeId], or null when it was never created.
Future<MeetingTypeDetails?> meetingTypeDetailsFor(EventStore store, MeetingTypeId meetingTypeId) async {
  final read = await store.read([
    (
      tag: 'meetingTypeId',
      value: meetingTypeId.value,
      eventTypes: const [MeetingTypeCreatedEvent, MeetingTypeEditedEvent],
    ),
  ]);
  final host = read.events.map((stored) => stored.event).whereType<MeetingTypeCreatedEvent>().firstOrNull;
  if (host == null) return null;
  final latest = read.events
      .map((stored) => stored.event)
      .where((event) => event is MeetingTypeCreatedEvent || event is MeetingTypeEditedEvent)
      .last;
  final (title, duration, location, schedule, description) = switch (latest) {
    MeetingTypeCreatedEvent(
      :final meetingTitle,
      :final durationMinutes,
      :final meetingLocation,
      :final scheduleId,
      :final meetingDescription,
    ) =>
      (meetingTitle, durationMinutes, meetingLocation, scheduleId, meetingDescription),
    MeetingTypeEditedEvent(
      :final meetingTitle,
      :final durationMinutes,
      :final meetingLocation,
      :final scheduleId,
      :final meetingDescription,
    ) =>
      (meetingTitle, durationMinutes, meetingLocation, scheduleId, meetingDescription),
    _ => throw StateError('unreachable: the query returns only created and edited events'),
  };
  return MeetingTypeDetails(
    hostId: host.hostId,
    meetingTitle: title,
    durationMinutes: duration,
    meetingLocation: location,
    scheduleId: schedule,
    meetingDescription: description,
  );
}

/// The availability schedules that [hostId] created, as (schedule id, schedule name) options for the form.
Future<List<(String, String)>> scheduleOptionsFor(EventStore store, HostId hostId) async {
  final read = await store.read([
    (tag: 'hostId', value: hostId.value, eventTypes: const [AvailabilityScheduleCreatedEvent]),
  ]);
  return [
    for (final stored in read.events)
      if (stored.event case final AvailabilityScheduleCreatedEvent event)
        (event.scheduleId.value, event.scheduleName.value),
  ];
}
