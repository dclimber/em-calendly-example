import 'package:em_calendly_example/composition/event_catalog.dart';
import 'package:em_calendly_example/platform/event_store/in_memory_event_store.dart';
import 'package:test/test.dart';

import 'event_store_contract.dart';

void main() {
  group('InMemoryEventStore', () {
    final catalog = buildEventCatalog();
    late InMemoryEventStore store;
    setUp(() => store = InMemoryEventStore(catalog));

    eventStoreContract(() => store);
  });
}
