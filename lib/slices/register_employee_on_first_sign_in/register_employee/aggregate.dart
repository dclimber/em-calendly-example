import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:fmodel/fmodel.dart';

import 'command.dart';
import 'decider.dart';
import 'state.dart';

/// The `employee` aggregate for `register_employee`, with a fresh event repository.
EventSourcingAggregate<RegisterEmployeeCommand, RegisterEmployeeState, EmployeeDirectoryEvent, NoMetadata, NoMetadata>
buildRegisterEmployeeAggregate(
  EventRepository<RegisterEmployeeCommand, EmployeeDirectoryEvent, NoMetadata, NoMetadata> repository,
) => createEventSourcingAggregate(decider: registerEmployeeDecider, eventRepository: repository);
