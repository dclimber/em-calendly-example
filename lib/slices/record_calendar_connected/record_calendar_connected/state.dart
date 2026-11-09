import '../../../bounded_contexts/host_setup/api.dart';

/// The lifecycle state of one host's calendar connection, folded from its `calendar_connection` events.
/// `lifecycle` is null before the first event.
final class RecordCalendarConnectedState {
  const RecordCalendarConnectedState({this.lifecycle});

  final CalendarConnectionLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is RecordCalendarConnectedState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'RecordCalendarConnectedState($lifecycle)';
}
