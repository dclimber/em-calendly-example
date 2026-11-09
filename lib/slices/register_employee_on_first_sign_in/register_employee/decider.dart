import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:fmodel/fmodel.dart';

import 'command.dart';
import 'state.dart';

/// The decider of the `employee` aggregate for `register_employee`.
///
/// The model states no invalid transition for the `register` transition, so the decider accepts the command in every
/// state. The processor prevents repeated registrations.
final registerEmployeeDecider = Decider<RegisterEmployeeCommand, RegisterEmployeeState, EmployeeDirectoryEvent>(
  initialState: const RegisterEmployeeState(),
  decide: (command, state) async* {
    yield EmployeeRegisteredEvent(
      employeeId: command.employeeId,
      employeeName: command.employeeName,
      employeeEmail: command.employeeEmail,
    );
  },
  evolve: (state, event) => switch (event) {
    EmployeeRegisteredEvent() => RegisterEmployeeState(lifecycle: EmployeeLifecycleState.registered),
  },
);
