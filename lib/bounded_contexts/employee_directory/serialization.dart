/// JSON codec and event contract of the `employee_directory` bounded context.
library;

import '../event_contract.dart';
import 'event_tags.dart';
import 'events.dart';
import 'value_objects.dart';

/// The event contract of the `employee_directory` bounded context.
const employeeDirectoryEventContract = EventContract<EmployeeDirectoryEvent>(
  context: 'employee_directory',
  types: {
    'EmployeeRegisteredEvent': EmployeeRegisteredEvent,
  },
  typeName: employeeDirectoryEventTypeName,
  stream: employeeDirectoryEventStream,
  tags: employeeDirectoryEventTags,
  encode: encodeEmployeeDirectoryEvent,
  decode: decodeEmployeeDirectoryEvent,
);

/// The JSON form of [e]. Keys are camelCase field names.
JsonMap encodeEmployeeDirectoryEvent(EmployeeDirectoryEvent e) => switch (e) {
  final EmployeeRegisteredEvent e => <String, Object?>{
    'employeeId': e.employeeId.value,
    'employeeName': e.employeeName.value,
    'employeeEmail': e.employeeEmail.value,
  },
};

/// The event of type [typeName] that [json] encodes.
///
/// Throws [ArgumentError] for an unknown [typeName].
EmployeeDirectoryEvent decodeEmployeeDirectoryEvent(String typeName, JsonMap json) => switch (typeName) {
  'EmployeeRegisteredEvent' => EmployeeRegisteredEvent(
    employeeId: EmployeeId(json['employeeId'] as String),
    employeeName: EmployeeName(json['employeeName'] as String),
    employeeEmail: EmployeeEmail(json['employeeEmail'] as String),
  ),
  _ => throw ArgumentError.value(typeName, 'typeName', 'Unknown employee_directory event type'),
};
