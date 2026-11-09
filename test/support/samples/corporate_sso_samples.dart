/// One sample of every `corporate_sso` event.
library;

import 'package:em_calendly_example/bounded_contexts/corporate_sso/api.dart';

/// One instance of every `corporate_sso` event, with HCL example values where they exist.
List<CorporateSsoEvent> sampleCorporateSsoEvents() => [
  CorporateSignInSucceededEvent(
    ssoSubject: 'okta|00u1a2b3c4',
    displayName: 'Alice Example',
    workEmail: 'alice@example.com',
  ),
];
