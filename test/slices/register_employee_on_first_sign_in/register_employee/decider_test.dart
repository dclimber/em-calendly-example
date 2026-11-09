import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/slices/register_employee_on_first_sign_in/register_employee/command.dart';
import 'package:em_calendly_example/slices/register_employee_on_first_sign_in/register_employee/decider.dart';
import 'package:em_calendly_example/slices/register_employee_on_first_sign_in/register_employee/state.dart';
import 'package:test/test.dart';

final _command = RegisterEmployeeCommand(
  employeeId: EmployeeId('okta|00u1a2b3c4'),
  employeeName: EmployeeName('Alice Example'),
  employeeEmail: EmployeeEmail('alice@example.com'),
);

void main() {
  // @requires no prior employee_directory events for the employee
  // @ensures scenario first_sign_in_registers_the_employee: exactly employee_registered with the command's fields
  test('first_sign_in_registers_the_employee', () async {
    final events = await registerEmployeeDecider.decide(_command, registerEmployeeDecider.initialState).toList();
    expect(events, [
      EmployeeRegisteredEvent(
        employeeId: _command.employeeId,
        employeeName: _command.employeeName,
        employeeEmail: _command.employeeEmail,
      ),
    ]);
  });

  // @requires an employee already in state registered
  // @ensures the model states no rule for register_employee in state registered, so the decider accepts it (see the
  //   lifecycle gap in the slice report); the processor prevents the repeat
  test('registered state accepts the command (no model rule)', () async {
    const registered = RegisterEmployeeState(lifecycle: EmployeeLifecycleState.registered);
    final events = await registerEmployeeDecider.decide(_command, registered).toList();
    expect(events.single, isA<EmployeeRegisteredEvent>());
  });

  // @requires any state
  // @ensures evolve moves the state to registered after employee_registered
  test('evolve sets registered', () {
    final event = EmployeeRegisteredEvent(
      employeeId: _command.employeeId,
      employeeName: _command.employeeName,
      employeeEmail: _command.employeeEmail,
    );
    final next = registerEmployeeDecider.evolve(registerEmployeeDecider.initialState, event);
    expect(next, const RegisterEmployeeState(lifecycle: EmployeeLifecycleState.registered));
  });

  // @requires the command
  // @ensures the command has value equality
  test('command equality', () {
    final same = RegisterEmployeeCommand(
      employeeId: _command.employeeId,
      employeeName: _command.employeeName,
      employeeEmail: _command.employeeEmail,
    );
    expect(same, equals(_command));
    expect(same.hashCode, _command.hashCode);
  });
}
