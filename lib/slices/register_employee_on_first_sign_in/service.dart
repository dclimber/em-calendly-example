import 'package:em_calendly_example/bounded_contexts/corporate_sso/api.dart';
import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/platform/event_store/event_store.dart';
import 'package:em_calendly_example/platform/view_store/view_state_store.dart';
import 'package:fmodel/fmodel.dart';

import 'processor_state.dart';
import 'publisher.dart';
import 'register_employee/command.dart';
import 'saga.dart';
import 'sign_ins_to_register/state.dart';
import 'sign_ins_to_register/view.dart';

/// Handles one `corporate_sign_in_succeeded` event: lists the sign-in, then runs the processor on it.
///
/// Every step is idempotent. The view replaces the document of the SSO subject, and the processor reads the
/// registration history, so a redelivered event registers nothing new.
final class RegisterEmployeeOnFirstSignInService {
  RegisterEmployeeOnFirstSignInService({required EventStore eventStore, required ViewStateStore viewStore})
    : _eventStore = eventStore,
      _signIns = SignInsToRegisterRepository(viewStore),
      _processor = createSagaManager<RegisterEmployeeInput, RegisterEmployeeCommand, NoMetadata, NoMetadata>(
        saga: registerEmployeeSaga,
        actionPublisher: createRegisterEmployeePublisher(eventStore),
      );

  final EventStore _eventStore;
  final SignInsToRegisterRepository _signIns;
  final SagaManager<RegisterEmployeeInput, RegisterEmployeeCommand, NoMetadata, NoMetadata> _processor;

  Future<void> handleSignIn(StoredEvent stored) async {
    final view = createMaterializedView<SignInToRegisterState?, StoredEvent, NoMetadata>(
      view: signInsToRegisterView.mapLeftOnEvent<StoredEvent>((s) => s.event as CorporateSsoEvent),
      viewStateRepository: _signIns,
    );
    final signIn = await view.handle(stored);
    // The view deletes a document only for a null state, which this event never produces.
    if (signIn == null) return;
    final history = await _loadHistory(signIn.employeeId.value);
    await _processor.handle((signIn: signIn, history: history)).toList();
  }

  Future<EmployeeRegistrationHistory> _loadHistory(String employeeId) async {
    final read = await _eventStore.read([
      (tag: 'employeeId', value: employeeId, eventTypes: const [EmployeeRegisteredEvent]),
    ]);
    var history = employeeRegistrationHistoryView.initialState;
    for (final stored in read.events) {
      history = employeeRegistrationHistoryView.evolve(history, stored.event as EmployeeDirectoryEvent);
    }
    return history;
  }
}
