import 'package:em_calendly_example/platform/view_store/in_memory_view_state_store.dart';
import 'package:test/test.dart';

import 'view_state_store_contract.dart';

void main() {
  group('InMemoryViewStateStore', () {
    late InMemoryViewStateStore store;
    setUp(() => store = InMemoryViewStateStore());
    viewStateStoreContract(() => store);
  });
}
