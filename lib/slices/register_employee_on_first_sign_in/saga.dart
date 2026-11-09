import 'package:fmodel/fmodel.dart';

import 'processor_state.dart';
import 'register_employee/command.dart';
import 'sign_ins_to_register/state.dart';

/// The read-model sign-in and the registration history that the processor decides on.
typedef RegisterEmployeeInput = ({SignInToRegisterState signIn, EmployeeRegistrationHistory history});

/// The processor `employee_registrar`: registers the sign-in's employee unless the scheduler already did.
final registerEmployeeSaga = saga<RegisterEmployeeInput, RegisterEmployeeCommand>((input) async* {
  final signIn = input.signIn;
  if (input.history.isRegistered(signIn.employeeId)) return;
  yield RegisterEmployeeCommand(
    employeeId: signIn.employeeId,
    employeeName: signIn.employeeName,
    employeeEmail: signIn.employeeEmail,
  );
});
