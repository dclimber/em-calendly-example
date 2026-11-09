import 'package:jaspr/jaspr.dart';

import 'format.dart';

/// An instant in the viewer's local time zone.
///
/// The server renders it in UTC. In the browser it hydrates and shows the local time, because slots are absolute
/// instants and each viewer sees them in their own time zone.
@client
class LocalTime extends StatelessComponent {
  const LocalTime({required this.iso, this.timeOnly = false, super.key});

  /// An ISO-8601 instant, for example `2027-03-22T09:00:00.000Z`.
  final String iso;

  /// Show `09:30` instead of the date and the time.
  final bool timeOnly;

  @override
  Component build(BuildContext context) {
    final instant = DateTime.parse(iso);
    final shown = kIsWeb ? instant.toLocal() : instant.toUtc();
    return Component.element(
      tag: 'time',
      attributes: {'datetime': instant.toUtc().toIso8601String()},
      children: [.text(timeOnly ? formatTime(shown) : formatDateTime(shown))],
    );
  }
}
