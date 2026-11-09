/// One sample of every `employee_directory` event.
library;

import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';

/// One instance of every `employee_directory` event, with HCL example values where they exist.
List<EmployeeDirectoryEvent> sampleEmployeeDirectoryEvents() => [
  EmployeeRegisteredEvent(
    employeeId: EmployeeId('278da51b-6e18-5001-ac5e-80b839ab5650'),
    employeeName: EmployeeName('Alice Example'),
    employeeEmail: EmployeeEmail('alice@example.com'),
  ),
];
