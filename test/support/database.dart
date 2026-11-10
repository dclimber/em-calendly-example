import 'dart:io';

import 'package:em_calendly_example/platform/postgres/database.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

/// The database of the db tests, next to the application's database on the same server.
///
/// Event subscriptions replay every stored event, so tests must not write into the database that `make serve` uses.
const testDatabaseName = 'scheduler_test';

/// A pool to [testDatabaseName] on the local Supabase server (`make db-up`), closed after the test file. The first
/// call creates the database and applies `supabase/migrations/`.
///
/// Tests that use it are tagged `db`. Events cannot be deleted from fstore-sql, so these tests use fresh ids.
Future<Pool<void>> testDatabase() async {
  final serverUrl = Uri.parse(Platform.environment['DATABASE_URL'] ?? localDatabaseUrl);
  await _ensureTestDatabase(serverUrl);
  final pool = openDatabase(serverUrl.replace(path: '/$testDatabaseName').toString());
  addTearDown(() => pool.close());
  return pool;
}

Future<void> _ensureTestDatabase(Uri serverUrl) async {
  final admin = await Connection.openFromUrl(serverUrl.toString());
  try {
    // Test files run in parallel; one of them creates and migrates the database.
    await admin.execute('SELECT pg_advisory_lock(hashtext(\'$testDatabaseName\'))');
    final exists = await admin.execute(
      Sql.indexed('SELECT 1 FROM pg_database WHERE datname = @1'),
      parameters: [testDatabaseName],
    );
    if (exists.isEmpty) await admin.execute('CREATE DATABASE $testDatabaseName');

    final test = await Connection.openFromUrl(serverUrl.replace(path: '/$testDatabaseName').toString());
    try {
      final migrated = await test.execute("SELECT to_regclass('fstore.view_states') IS NOT NULL");
      if (migrated.first[0] != true) {
        final files =
            Directory('supabase/migrations').listSync().whereType<File>().where((f) => f.path.endsWith('.sql')).toList()
              ..sort((a, b) => a.path.compareTo(b.path));
        for (final file in files) {
          await test.execute(file.readAsStringSync(), queryMode: QueryMode.simple);
        }
      }
    } finally {
      await test.close();
    }
    await admin.execute('SELECT pg_advisory_unlock(hashtext(\'$testDatabaseName\'))');
  } finally {
    await admin.close();
  }
}
