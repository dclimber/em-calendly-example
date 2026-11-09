import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/event_store.dart';
import '../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `my_availability_schedules`: one document per schedule id.
final class MyAvailabilitySchedulesRepository extends DocumentViewStateRepository<AvailabilitySchedule> {
  MyAvailabilitySchedulesRepository(super.store);

  @override
  String get viewName => 'my_availability_schedules';

  @override
  String? keyOf(StoredEvent event) => switch (event.event) {
    AvailabilityScheduleCreatedEvent(:final scheduleId) => scheduleId.value,
    WeeklyHoursSetEvent(:final scheduleId) => scheduleId.value,
    DateExceptionAddedEvent(:final scheduleId) => scheduleId.value,
    DateExceptionChangedEvent(:final scheduleId) => scheduleId.value,
    DateExceptionRemovedEvent(:final scheduleId) => scheduleId.value,
    BookingLimitsSetEvent(:final scheduleId) => scheduleId.value,
    _ => null,
  };

  @override
  String keyOfState(AvailabilitySchedule state) => state.scheduleId.value;

  @override
  JsonMap encodeState(AvailabilitySchedule state) => state.toJson();

  @override
  AvailabilitySchedule decodeState(JsonMap json) => AvailabilitySchedule.fromJson(json);
}
