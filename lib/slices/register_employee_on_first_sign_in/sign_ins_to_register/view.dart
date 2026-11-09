import 'package:em_calendly_example/bounded_contexts/corporate_sso/api.dart';
import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/platform/event_store/event_store.dart';
import 'package:em_calendly_example/platform/view_store/materialized_view.dart';
import 'package:fmodel/fmodel.dart';

import 'state.dart';

/// The pure view of `sign_ins_to_register`: the latest sign-in of each SSO subject.
final signInsToRegisterView = View<SignInToRegisterState?, CorporateSsoEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    CorporateSignInSucceededEvent() => SignInToRegisterState(
      employeeId: EmployeeId(event.ssoSubject),
      employeeName: EmployeeName(event.displayName),
      employeeEmail: EmployeeEmail(event.workEmail),
    ),
  },
);

/// The document store of `sign_ins_to_register`, one document per SSO subject.
final class SignInsToRegisterRepository extends DocumentViewStateRepository<SignInToRegisterState> {
  SignInsToRegisterRepository(super.store);

  @override
  String get viewName => 'sign_ins_to_register';

  @override
  String? keyOf(StoredEvent event) {
    final e = event.event;
    return e is CorporateSignInSucceededEvent ? e.ssoSubject : null;
  }

  @override
  String keyOfState(SignInToRegisterState state) => state.employeeId.value;

  @override
  JsonMap encodeState(SignInToRegisterState state) => state.toJson();

  @override
  SignInToRegisterState decodeState(JsonMap json) => SignInToRegisterState.fromJson(json);
}
