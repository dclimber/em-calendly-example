import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/slices/register_employee_on_first_sign_in/processor_state.dart';
import 'package:em_calendly_example/slices/register_employee_on_first_sign_in/saga.dart';
import 'package:em_calendly_example/slices/register_employee_on_first_sign_in/sign_ins_to_register/state.dart';
import 'package:test/test.dart';

final _signIn = SignInToRegisterState(
  employeeId: EmployeeId('okta|00u1a2b3c4'),
  employeeName: EmployeeName('Alice Example'),
  employeeEmail: EmployeeEmail('alice@example.com'),
);

void main() {
  // @requires a sign-in and an empty registration history
  // @ensures scenario first_sign_in_registers_the_employee: the processor emits one register_employee command
  test('first_sign_in_registers_the_employee', () async {
    final commands = await registerEmployeeSaga.react((
      signIn: _signIn,
      history: const EmployeeRegistrationHistory(),
    )).toList();
    expect(commands.single.employeeId, _signIn.employeeId);
    expect(commands.single.employeeName, _signIn.employeeName);
    expect(commands.single.employeeEmail, _signIn.employeeEmail);
  });

  // @requires the employee already recorded as registered
  // @ensures scenario repeat_sign_in_registers_nothing: expect_no_dispatch for register_employee
  test('repeat_sign_in_registers_nothing', () async {
    final history = employeeRegistrationHistoryView.evolve(
      employeeRegistrationHistoryView.initialState,
      EmployeeRegisteredEvent(
        employeeId: _signIn.employeeId,
        employeeName: _signIn.employeeName,
        employeeEmail: _signIn.employeeEmail,
      ),
    );
    final commands = await registerEmployeeSaga.react((signIn: _signIn, history: history)).toList();
    expect(commands, isEmpty);
  });

  // @requires a history with any set of registered employees
  // @ensures the processor emits a command exactly when the sign-in's employee is not registered
  test('dispatch exactly when not registered', () async {
    final others = [EmployeeId('other-1'), EmployeeId('other-2')];
    for (final registered in [false, true]) {
      final history = EmployeeRegistrationHistory(
        registeredIds: {...others.map((id) => id.value), if (registered) _signIn.employeeId.value},
      );
      final commands = await registerEmployeeSaga.react((signIn: _signIn, history: history)).toList();
      expect(commands.length, registered ? 0 : 1, reason: 'registered: $registered');
    }
  });
}
