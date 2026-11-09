import '../../bounded_contexts/host_setup/api.dart';

/// The lifecycle state of one availability schedule. `lifecycle` is null before the first event.
final class CreateAvailabilityScheduleState {
  const CreateAvailabilityScheduleState({this.lifecycle});

  final AvailabilityScheduleLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is CreateAvailabilityScheduleState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'CreateAvailabilityScheduleState($lifecycle)';
}
