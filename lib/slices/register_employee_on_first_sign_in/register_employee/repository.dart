import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/platform/event_store/consistent_event_repository.dart';
import 'package:em_calendly_example/platform/event_store/event_store.dart';

import 'command.dart';

/// Reads the `employee_directory` history of the employee that a command names.
final class RegisterEmployeeEventRepository
    extends ConsistentEventRepository<RegisterEmployeeCommand, EmployeeDirectoryEvent> {
  RegisterEmployeeEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RegisterEmployeeCommand command) => [
    (tag: 'employeeId', value: command.employeeId.value, eventTypes: const [EmployeeRegisteredEvent]),
  ];
}
