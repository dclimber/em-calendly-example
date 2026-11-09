import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/event_store.dart';

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
