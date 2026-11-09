import 'package:shelf/shelf.dart';

/// The signed-in employee who sends a request. Every actor of the model is an authenticated employee.
final class Viewer {
  const Viewer({required this.employeeId, required this.name, required this.email});

  /// The Supabase user id, which is also the `employee_id` (and `host_id`, `booker_id`) of the model.
  final String employeeId;
  final String name;
  final String email;
}

/// A GET request for a page.
final class PageRequest {
  const PageRequest({
    required this.viewer,
    required this.pathParameters,
    required this.query,
    required this.path,
  });

  final Viewer viewer;

  /// The values of the `<name>` segments of the route, for example `meetingTypeId`.
  final Map<String, String> pathParameters;
  final Map<String, String> query;

  /// The requested path, with its query.
  final String path;

  /// The value of the path parameter [name]. The route guarantees that it exists.
  String param(String name) => pathParameters[name] ?? (throw ArgumentError('No path parameter $name'));

  /// The flash message after a redirect with [noticeRedirect].
  String? get notice => query['notice'];

  /// The error message after a redirect with [errorRedirect].
  String? get error => query['error'];
}

/// A POST request with an `application/x-www-form-urlencoded` body.
final class FormRequest {
  const FormRequest({required this.viewer, required this.pathParameters, required this.fields, required this.request});

  final Viewer viewer;
  final Map<String, String> pathParameters;

  /// Every value of each field, in order. A checkbox or a repeated input gives several values.
  final Map<String, List<String>> fields;
  final Request request;

  String param(String name) => pathParameters[name] ?? (throw ArgumentError('No path parameter $name'));

  /// The first value of [name], trimmed, or null when the field is missing or empty.
  String? field(String name) {
    final value = fields[name]?.firstOrNull?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  /// The first value of [name], trimmed. Throws [FormInputError] when it is missing or empty.
  String requiredField(String name, {String? label}) =>
      field(name) ?? (throw FormInputError('${label ?? name} is required.'));

  /// Every value of [name], in order (empty strings included).
  List<String> all(String name) => fields[name] ?? const [];
}

/// The form input cannot become a command. [message] is safe to show to the person.
final class FormInputError implements Exception {
  const FormInputError(this.message);

  final String message;

  @override
  String toString() => 'FormInputError: $message';
}

/// Handles a form post and returns a response, usually a redirect.
typedef FormHandler = Future<Response> Function(FormRequest request);

/// Parses an `application/x-www-form-urlencoded` body, keeping repeated fields.
Map<String, List<String>> parseFormBody(String body) {
  final fields = <String, List<String>>{};
  for (final pair in body.split('&')) {
    if (pair.isEmpty) continue;
    final index = pair.indexOf('=');
    final name = Uri.decodeQueryComponent(index < 0 ? pair : pair.substring(0, index));
    final value = index < 0 ? '' : Uri.decodeQueryComponent(pair.substring(index + 1));
    (fields[name] ??= []).add(value);
  }
  return fields;
}

/// A `303 See Other` redirect to [path].
Response seeOther(String path) => Response(303, headers: {'location': path});

/// A redirect to [path] that shows [message] as a notice.
Response noticeRedirect(String path, String message) => seeOther(_withQuery(path, 'notice', message));

/// A redirect to [path] that shows [message] as an error.
Response errorRedirect(String path, String message) => seeOther(_withQuery(path, 'error', message));

String _withQuery(String path, String name, String value) {
  final uri = Uri.parse(path);
  return uri.replace(queryParameters: {...uri.queryParameters, name: value}).toString();
}
