import '../../../bounded_contexts/host_setup/api.dart';

/// The lifecycle state of one host's calendar connection, folded from its `calendar_connection` events.
/// `lifecycle` is null before the first event.
final class RecordConnectionFailureState {
  const RecordConnectionFailureState({this.lifecycle});

  final CalendarConnectionLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is RecordConnectionFailureState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'RecordConnectionFailureState($lifecycle)';
}
