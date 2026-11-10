import 'package:jaspr/jaspr.dart';
import 'package:shelf/shelf.dart';

import '../platform/event_streaming/event_subscription.dart';
import '../platform/jobs/job_scheduler.dart';
import '../platform/web/http.dart';
import '../ui/paths.dart';
import 'app_services.dart';

/// One slice of the model. Its `module.dart` exposes one const instance, and `slice_registry.dart` lists it.
abstract interface class VerticalSlice {
  /// The slice folder name, for example `reserve_meeting_slot`.
  String get name;

  /// Registers the routes, pages, navigation entries, subscriptions, and jobs of the slice.
  void register(SliceRegistrar registrar, AppServices services);
}

/// Builds the page body for a request. Return an `AsyncStatelessComponent` to load data on the server.
typedef PageBuilder = Component Function(PageRequest request);

/// A link in the main navigation.
final class NavItem {
  const NavItem({required this.label, required this.path, required this.order});

  final String label;
  final String path;

  /// The position in the navigation; lower comes first.
  final int order;
}

final class PageRoute {
  const PageRoute({required this.path, required this.title, required this.builder});

  /// A shelf_router pattern, for example `/book/<meetingTypeId>`.
  final String path;
  final String title;
  final PageBuilder builder;
}

final class FormRoute {
  const FormRoute({required this.path, required this.handler});

  final String path;
  final FormHandler handler;
}

/// What the slices registered. Composition turns it into the server.
final class SliceRegistrar {
  final List<PageRoute> pages = [];
  final List<FormRoute> forms = [];
  final List<NavItem> navigation = [];
  final List<EventSubscription> subscriptions = [];
  final List<ScheduledJob> jobs = [];
  final List<(String, Handler)> rawRoutes = [];
  final Set<String> _paths = {};

  void _claim(String method, String path) {
    if (!path.startsWith('$appRoot/')) throw ArgumentError.value(path, 'path', 'Slice routes live under $appRoot/');
    if (!_paths.add('$method $path')) throw StateError('Route $method $path is registered twice');
  }

  /// A page at [path] (GET), rendered inside the application layout with the title [title].
  void page(String path, {required String title, required PageBuilder builder}) {
    _claim('GET', path);
    pages.add(PageRoute(path: path, title: title, builder: builder));
  }

  /// A form post at [path] (POST) from a signed-in employee.
  void form(String path, FormHandler handler) {
    _claim('POST', path);
    forms.add(FormRoute(path: path, handler: handler));
  }

  /// A GET route that returns its own response (not a page), for example a JSON endpoint.
  void get(String path, Handler handler) {
    _claim('GET', path);
    rawRoutes.add((path, handler));
  }

  void nav(NavItem item) => navigation.add(item);

  /// An event consumer: a materialized view, an automation, or a translation.
  void subscribe(EventSubscription subscription) => subscriptions.add(subscription);

  void schedule(ScheduledJob job) => jobs.add(job);
}
