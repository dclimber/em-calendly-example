import 'package:postgres/postgres.dart';

/// The database of the local Supabase stack (`supabase start`).
const localDatabaseUrl = 'postgresql://postgres:postgres@127.0.0.1:54322/postgres?sslmode=disable';

/// A connection pool for [url] (`postgresql://user:password@host:port/db?sslmode=...`).
Pool<void> openDatabase(String url) => Pool.withUrl(url);

/// A statement with native `$1`, `$2`, ... parameters, sent to the server as written.
Sql sql(String statement) => Sql(statement);
