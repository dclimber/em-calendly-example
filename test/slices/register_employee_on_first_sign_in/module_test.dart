import 'package:em_calendly_example/bounded_contexts/corporate_sso/api.dart';
import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/slices/register_employee_on_first_sign_in/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

void main() {
  final signIn = CorporateSignInSucceededEvent(
    ssoSubject: 'okta|00u1a2b3c4',
    displayName: 'Alice Example',
    workEmail: 'alice@example.com',
  );

  // @requires a corporate sign-in and the slice running alone
  // @ensures the sign-in registers the employee once, and a repeated sign-in registers nothing more
  test('first sign-in registers once; repeats register nothing', () async {
    final t = TestApp(slices: const [RegisterEmployeeOnFirstSignInSlice()]);
    await t.start();

    await t.given([signIn]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is EmployeeRegisteredEvent), hasLength(1));

    await t.given([signIn]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is EmployeeRegisteredEvent), hasLength(1));
  });

  // @requires a corporate sign-in
  // @ensures the sign-in is kept in the sign_ins_to_register view, keyed by its SSO subject
  test('sign-in lands in the sign_ins_to_register view', () async {
    final t = TestApp(slices: const [RegisterEmployeeOnFirstSignInSlice()]);
    await t.start();

    await t.given([signIn]);
    await t.drain();
    expect(await t.views.get('sign_ins_to_register', signIn.ssoSubject), isNotNull);
  });
}
