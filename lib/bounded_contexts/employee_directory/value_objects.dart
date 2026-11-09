/// Value objects of the `employee_directory` bounded context.
library;

/// The `employee_id` field type (String, identity).
extension type const EmployeeId._(String value) {
  factory EmployeeId(String value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'EmployeeId must not be empty');
    }
    return EmployeeId._(value);
  }
}

/// The `employee_name` field type (String).
extension type const EmployeeName._(String value) {
  factory EmployeeName(String value) => EmployeeName._(value);
}

/// The `employee_email` field type (String).
extension type const EmployeeEmail._(String value) {
  factory EmployeeEmail(String value) => EmployeeEmail._(value);
}
