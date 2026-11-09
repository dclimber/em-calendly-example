import '../../bounded_contexts/host_setup/api.dart';

/// The lifecycle state of one host's calendar connection. `lifecycle` is null before the first event.
final class StartCalendarConnectionState {
  const StartCalendarConnectionState({this.lifecycle});

  final CalendarConnectionLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is StartCalendarConnectionState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'StartCalendarConnectionState($lifecycle)';
}
