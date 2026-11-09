/// Events of the `corporate_sso` bounded context.
library;

import '../event_contract.dart';

/// An event of the `corporate_sso` bounded context.
///
/// The corporate single sign-on system (external).
sealed class CorporateSsoEvent implements DomainEvent {
  const CorporateSsoEvent();
}

/// The `corporate_sign_in_succeeded` event.
final class CorporateSignInSucceededEvent extends CorporateSsoEvent {
  const CorporateSignInSucceededEvent({required this.ssoSubject, required this.displayName, required this.workEmail});

  final String ssoSubject;
  final String displayName;
  final String workEmail;

  @override
  bool operator ==(Object other) =>
      other is CorporateSignInSucceededEvent &&
      other.ssoSubject == ssoSubject &&
      other.displayName == displayName &&
      other.workEmail == workEmail;

  @override
  int get hashCode => Object.hash(runtimeType, ssoSubject, displayName, workEmail);

  @override
  String toString() =>
      'CorporateSignInSucceededEvent(ssoSubject: $ssoSubject, displayName: $displayName, workEmail: $workEmail)';
}
