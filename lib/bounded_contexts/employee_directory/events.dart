/// Events of the `employee_directory` bounded context.
library;

import '../event_contract.dart';
import 'value_objects.dart';

/// An event of the `employee_directory` bounded context.
///
/// Employees known to the scheduler through corporate sign-in.
sealed class EmployeeDirectoryEvent implements DomainEvent {
  const EmployeeDirectoryEvent();
}

/// The `employee_registered` event.
///
/// Aggregate: `employee`.
final class EmployeeRegisteredEvent extends EmployeeDirectoryEvent {
  const EmployeeRegisteredEvent({required this.employeeId, required this.employeeName, required this.employeeEmail});

  final EmployeeId employeeId;
  final EmployeeName employeeName;
  final EmployeeEmail employeeEmail;

  @override
  bool operator ==(Object other) =>
      other is EmployeeRegisteredEvent &&
      other.employeeId == employeeId &&
      other.employeeName == employeeName &&
      other.employeeEmail == employeeEmail;

  @override
  int get hashCode => Object.hash(runtimeType, employeeId, employeeName, employeeEmail);

  @override
  String toString() =>
      'EmployeeRegisteredEvent(employeeId: $employeeId, employeeName: $employeeName, employeeEmail: $employeeEmail)';
}
