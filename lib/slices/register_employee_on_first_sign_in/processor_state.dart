import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:fmodel/fmodel.dart';

/// The employees that the scheduler has already registered. The processor reads it to register each one once.
final class EmployeeRegistrationHistory {
  const EmployeeRegistrationHistory({this.registeredIds = const {}});

  final Set<String> registeredIds;

  bool isRegistered(EmployeeId employeeId) => registeredIds.contains(employeeId.value);

  @override
  bool operator ==(Object other) =>
      other is EmployeeRegistrationHistory && _sameIds(other.registeredIds, registeredIds);

  @override
  int get hashCode => Object.hashAllUnordered(registeredIds);

  static bool _sameIds(Set<String> a, Set<String> b) => a.length == b.length && a.containsAll(b);

  @override
  String toString() => 'EmployeeRegistrationHistory($registeredIds)';
}

/// Folds `employee_registered` events into the registration history.
final employeeRegistrationHistoryView = View<EmployeeRegistrationHistory, EmployeeDirectoryEvent>(
  initialState: const EmployeeRegistrationHistory(),
  evolve: (state, event) => switch (event) {
    EmployeeRegisteredEvent() => EmployeeRegistrationHistory(
      registeredIds: {...state.registeredIds, event.employeeId.value},
    ),
  },
);
