import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';

/// The state of one employee, folded from its `employee_directory` events.
final class RegisterEmployeeState {
  const RegisterEmployeeState({this.lifecycle});

  /// The lifecycle state of the employee, or null before its first event.
  final EmployeeLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is RegisterEmployeeState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'RegisterEmployeeState($lifecycle)';
}
