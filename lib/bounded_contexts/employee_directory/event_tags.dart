/// Type names, tags, and streams of the `employee_directory` events.
library;

import '../event_contract.dart';
import 'events.dart';

/// The stable type name of [e]: its Dart class name.
String employeeDirectoryEventTypeName(EmployeeDirectoryEvent e) => switch (e) {
  EmployeeRegisteredEvent() => 'EmployeeRegisteredEvent',
};

/// The tags of [e]: identity fields, correlation keys, and deduplication keys.
List<EventTag> employeeDirectoryEventTags(EmployeeDirectoryEvent e) => switch (e) {
  final EmployeeRegisteredEvent e => [(tag: 'employeeId', value: e.employeeId.value)],
};

/// The fstore-sql stream of [e].
EventStream employeeDirectoryEventStream(EmployeeDirectoryEvent e) => switch (e) {
  final EmployeeRegisteredEvent e => (type: 'employee', id: e.employeeId.value),
};
