import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';

/// Registers a new employee in the directory.
final class RegisterEmployeeCommand {
  const RegisterEmployeeCommand({required this.employeeId, required this.employeeName, required this.employeeEmail});

  final EmployeeId employeeId;
  final EmployeeName employeeName;
  final EmployeeEmail employeeEmail;

  @override
  bool operator ==(Object other) =>
      other is RegisterEmployeeCommand &&
      other.employeeId == employeeId &&
      other.employeeName == employeeName &&
      other.employeeEmail == employeeEmail;

  @override
  int get hashCode => Object.hash(employeeId, employeeName, employeeEmail);

  @override
  String toString() => 'RegisterEmployeeCommand($employeeId, $employeeName, $employeeEmail)';
}
