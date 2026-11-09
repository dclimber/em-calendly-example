import 'package:em_calendly_example/bounded_contexts/corporate_sso/api.dart';
import 'package:em_calendly_example/slices/register_employee_on_first_sign_in/sign_ins_to_register/view.dart';
import 'package:test/test.dart';

final _signIn = CorporateSignInSucceededEvent(
  ssoSubject: 'okta|00u1a2b3c4',
  displayName: 'Alice Example',
  workEmail: 'alice@example.com',
);

void main() {
  // @requires a corporate_sign_in_succeeded event
  // @ensures scenario sign_in_is_listed_for_registration: the view holds the sign-in keyed by its SSO subject
  test('sign_in_is_listed_for_registration', () {
    final state = signInsToRegisterView.evolve(signInsToRegisterView.initialState, _signIn);
    expect(state, isNotNull);
    expect(state!.employeeId.value, _signIn.ssoSubject);
    expect(state.employeeName.value, _signIn.displayName);
    expect(state.employeeEmail.value, _signIn.workEmail);
  });

  // @requires the same sign-in applied twice
  // @ensures folding a repeated sign-in yields the same state (idempotent)
  test('repeated sign-in yields the same state', () {
    final once = signInsToRegisterView.evolve(signInsToRegisterView.initialState, _signIn);
    final twice = signInsToRegisterView.evolve(once, _signIn);
    expect(twice, equals(once));
  });
}
