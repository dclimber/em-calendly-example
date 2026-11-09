import 'dart:io';

import 'package:em_calendly_example/platform/postgres/database.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

/// A pool to the local Supabase database (`make db-up`), closed after the test file.
///
/// Tests that use it are tagged `db`. Events cannot be deleted from fstore-sql, so these tests use fresh ids.
Pool<void> testDatabase() {
  final pool = openDatabase(Platform.environment['DATABASE_URL'] ?? localDatabaseUrl);
  addTearDown(() => pool.close());
  return pool;
}
