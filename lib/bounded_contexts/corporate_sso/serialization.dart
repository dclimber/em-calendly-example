/// JSON codec and event contract of the `corporate_sso` bounded context.
library;

import '../event_contract.dart';
import 'event_tags.dart';
import 'events.dart';

/// The event contract of the `corporate_sso` bounded context.
const corporateSsoEventContract = EventContract<CorporateSsoEvent>(
  context: 'corporate_sso',
  types: {
    'CorporateSignInSucceededEvent': CorporateSignInSucceededEvent,
  },
  typeName: corporateSsoEventTypeName,
  stream: corporateSsoEventStream,
  tags: corporateSsoEventTags,
  encode: encodeCorporateSsoEvent,
  decode: decodeCorporateSsoEvent,
);

/// The JSON form of [e]. Keys are camelCase field names.
JsonMap encodeCorporateSsoEvent(CorporateSsoEvent e) => switch (e) {
  final CorporateSignInSucceededEvent e => <String, Object?>{
    'ssoSubject': e.ssoSubject,
    'displayName': e.displayName,
    'workEmail': e.workEmail,
  },
};

/// The event of type [typeName] that [json] encodes.
///
/// Throws [ArgumentError] for an unknown [typeName].
CorporateSsoEvent decodeCorporateSsoEvent(String typeName, JsonMap json) => switch (typeName) {
  'CorporateSignInSucceededEvent' => CorporateSignInSucceededEvent(
    ssoSubject: json['ssoSubject'] as String,
    displayName: json['displayName'] as String,
    workEmail: json['workEmail'] as String,
  ),
  _ => throw ArgumentError.value(typeName, 'typeName', 'Unknown corporate_sso event type'),
};
