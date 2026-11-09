@Tags(['db'])
library;

import 'package:em_calendly_example/platform/view_store/postgres_view_state_store.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../support/database.dart';
import 'view_state_store_contract.dart';

void main() {
  group('PostgresViewStateStore', () {
    late Pool<void> db;
    setUpAll(() => db = testDatabase());
    viewStateStoreContract(() => PostgresViewStateStore(db));
  });
}
