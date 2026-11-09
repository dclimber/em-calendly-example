import 'package:em_calendly_example/bounded_contexts/corporate_sso/api.dart';
import 'package:em_calendly_example/composition/app_services.dart';
import 'package:em_calendly_example/composition/vertical_slice.dart';
import 'package:em_calendly_example/platform/event_streaming/event_subscription.dart';

import 'service.dart';

/// The automation `register_employee_on_first_sign_in`: registers an employee on the first corporate sign-in.
final class RegisterEmployeeOnFirstSignInSlice implements VerticalSlice {
  const RegisterEmployeeOnFirstSignInSlice();

  @override
  String get name => 'register_employee_on_first_sign_in';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = RegisterEmployeeOnFirstSignInService(
      eventStore: services.eventStore,
      viewStore: services.viewStore,
    );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:register_employee_on_first_sign_in',
        eventTypes: {CorporateSignInSucceededEvent},
        handle: service.handleSignIn,
      ),
    );
  }
}
