/// The entrypoint of the server.
library;

import 'dart:async';
import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'composition/application.dart';
import 'composition/bootstrap.dart';
import 'main.server.options.dart';

// `jaspr serve` runs main again after a hot reload; the previous instance is stopped first.
HttpServer? _server;
Application? _app;
StreamSubscription<LogRecord>? _logs;

Future<void> main() async {
  await _server?.close(force: true);
  await _app?.stop();
  await _logs?.cancel();

  Logger.root.level = Level.INFO;
  _logs = Logger.root.onRecord.listen((r) {
    stdout.writeln('${r.time.toIso8601String()} ${r.level.name} ${r.loggerName}: ${r.message}');
    if (r.error != null) stdout.writeln('  ${r.error}');
    if (r.stackTrace != null && r.level >= Level.SEVERE) stdout.writeln(r.stackTrace);
  });

  Jaspr.initializeApp(options: defaultServerOptions);

  final app = _app = bootstrap(Environment.fromPlatform());
  await app.start();

  // jaspr's handler tries static files first, and that consumes a request body. Form posts skip it.
  final pages = serveApp((request, render) => app.handle(request, render));
  Future<Response> handler(Request request) async {
    if (request.method == 'GET' || request.method == 'HEAD') return pages(request);
    return app.handle(request, (document) async {
      final rendered = await renderComponent(document, request: request);
      return Response(rendered.statusCode, body: rendered.body, headers: rendered.headers);
    });
  }

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port, shared: true);
  Logger('server').info('Serving at http://localhost:${server.port}');
}
