import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import '../platform/auth/authenticator.dart';
import '../platform/corporate_calendar/calendar_bridge.dart';
import '../platform/corporate_calendar/corporate_calendar.dart';
import '../platform/corporate_calendar/google_corporate_calendar.dart';
import '../platform/corporate_calendar/mock_corporate_calendar.dart';
import '../platform/event_store/postgres_event_store.dart';
import '../platform/event_streaming/postgres_event_streamer.dart';
import '../platform/mail/mailer.dart';
import '../platform/postgres/database.dart';
import '../platform/time/clock.dart';
import '../platform/view_store/postgres_view_state_store.dart';
import 'app_services.dart';
import 'application.dart';
import 'event_catalog.dart';
import 'slice_registry.dart';

/// The configuration of a running server. Every value has a default for the local Supabase stack.
final class Environment {
  const Environment({
    this.databaseUrl = localDatabaseUrl,
    this.supabaseUrl = 'http://127.0.0.1:54321',
    this.supabaseApiKey = 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
    this.smtpHost = '127.0.0.1',
    this.smtpPort = 54325,
    this.mailFrom = 'scheduler@example.com',
    this.publicBaseUrl = 'http://localhost:8080',
    this.googleCredentialsPath,
  });

  /// Reads `DATABASE_URL`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SMTP_HOST`, `SMTP_PORT`, `MAIL_FROM`,
  /// `PUBLIC_BASE_URL`, and `GOOGLE_APPLICATION_CREDENTIALS`.
  factory Environment.fromPlatform([Map<String, String>? variables]) {
    final env = variables ?? Platform.environment;
    const d = Environment();
    String? value(String name) => (env[name]?.isEmpty ?? true) ? null : env[name];
    return Environment(
      databaseUrl: value('DATABASE_URL') ?? d.databaseUrl,
      supabaseUrl: value('SUPABASE_URL') ?? d.supabaseUrl,
      supabaseApiKey: value('SUPABASE_PUBLISHABLE_KEY') ?? d.supabaseApiKey,
      smtpHost: value('SMTP_HOST') ?? d.smtpHost,
      smtpPort: int.parse(value('SMTP_PORT') ?? '${d.smtpPort}'),
      mailFrom: value('MAIL_FROM') ?? d.mailFrom,
      publicBaseUrl: value('PUBLIC_BASE_URL') ?? d.publicBaseUrl,
      googleCredentialsPath: value('GOOGLE_APPLICATION_CREDENTIALS'),
    );
  }

  final String databaseUrl;
  final String supabaseUrl;
  final String supabaseApiKey;
  final String smtpHost;
  final int smtpPort;
  final String mailFrom;
  final String publicBaseUrl;

  /// The JSON key file of a Google service account with domain-wide delegation. Without it, the mock calendar runs.
  final String? googleCredentialsPath;
}

/// Builds the production [Application]: fstore-sql on Supabase Postgres, Supabase Auth, SMTP, and Google Calendar
/// or the mock calendar.
Application bootstrap(Environment env) {
  final log = Logger('bootstrap');
  final catalog = buildEventCatalog();
  final db = openDatabase(env.databaseUrl);
  final eventStore = PostgresEventStore(db, catalog);
  final viewStore = PostgresViewStateStore(db);
  const clock = SystemClock();

  final MockCorporateCalendar? mock;
  final CorporateCalendar calendar;
  if (env.googleCredentialsPath case final path?) {
    log.info('Corporate calendar: Google Calendar (service account $path)');
    calendar = GoogleCorporateCalendar(jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>);
    mock = null;
  } else {
    log.info('Corporate calendar: mock (set GOOGLE_APPLICATION_CREDENTIALS for Google Calendar)');
    calendar = mock = MockCorporateCalendar();
  }

  final services = AppServices(
    eventStore: eventStore,
    viewStore: viewStore,
    clock: clock,
    ids: const UuidGenerator(),
    mailer: SmtpMailer(host: env.smtpHost, port: env.smtpPort, from: env.mailFrom),
    publicBaseUrl: Uri.parse(env.publicBaseUrl),
  );
  return Application(
    services: services,
    slices: verticalSlices,
    authenticator: SupabaseAuthenticator(supabaseUrl: Uri.parse(env.supabaseUrl), apiKey: env.supabaseApiKey),
    streamer: PostgresEventStreamer(db, eventStore, catalog),
    calendarBridge: CalendarBridge(eventStore: eventStore, viewStore: viewStore, calendar: calendar, clock: clock),
    mockCalendar: mock,
  );
}
