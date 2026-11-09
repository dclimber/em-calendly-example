/// Type names, tags, and streams of the `corporate_sso` events.
library;

import '../event_contract.dart';
import 'events.dart';

/// The stable type name of [e]: its Dart class name.
String corporateSsoEventTypeName(CorporateSsoEvent e) => switch (e) {
  CorporateSignInSucceededEvent() => 'CorporateSignInSucceededEvent',
};

/// The tags of [e]: identity fields, correlation keys, and deduplication keys.
List<EventTag> corporateSsoEventTags(CorporateSsoEvent e) => switch (e) {
  final CorporateSignInSucceededEvent e => [(tag: 'ssoSubject', value: e.ssoSubject)],
};

/// The fstore-sql stream of [e].
EventStream corporateSsoEventStream(CorporateSsoEvent e) => switch (e) {
  final CorporateSignInSucceededEvent e => (type: 'corporate_sso', id: e.ssoSubject),
};
