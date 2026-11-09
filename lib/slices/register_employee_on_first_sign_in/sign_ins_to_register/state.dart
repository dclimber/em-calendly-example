import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';

/// One corporate sign-in that has reported an employee to the scheduler. Its key is the SSO subject.
final class SignInToRegisterState {
  const SignInToRegisterState({required this.employeeId, required this.employeeName, required this.employeeEmail});

  factory SignInToRegisterState.fromJson(JsonMap json) => SignInToRegisterState(
    employeeId: EmployeeId(json['employeeId']! as String),
    employeeName: EmployeeName(json['employeeName']! as String),
    employeeEmail: EmployeeEmail(json['employeeEmail']! as String),
  );

  final EmployeeId employeeId;
  final EmployeeName employeeName;
  final EmployeeEmail employeeEmail;

  JsonMap toJson() => {
    'employeeId': employeeId.value,
    'employeeName': employeeName.value,
    'employeeEmail': employeeEmail.value,
  };

  @override
  bool operator ==(Object other) =>
      other is SignInToRegisterState &&
      other.employeeId == employeeId &&
      other.employeeName == employeeName &&
      other.employeeEmail == employeeEmail;

  @override
  int get hashCode => Object.hash(employeeId, employeeName, employeeEmail);

  @override
  String toString() => 'SignInToRegisterState($employeeId, $employeeName, $employeeEmail)';
}
