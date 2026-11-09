import 'dart:async';

import 'package:logging/logging.dart';

/// Work that runs on a timer, for example a worker that completes meetings whose end time has passed.
final class ScheduledJob {
  const ScheduledJob({required this.name, required this.interval, required this.run});

  final String name;
  final Duration interval;

  /// One run. Runs never overlap. An exception is logged, and the next tick runs again.
  final Future<void> Function() run;
}

/// Runs [ScheduledJob]s with periodic timers.
final class JobScheduler {
  final _log = Logger('jobs');
  final List<Timer> _timers = [];

  void start(List<ScheduledJob> jobs) {
    for (final job in jobs) {
      var busy = false;
      _timers.add(
        Timer.periodic(job.interval, (_) async {
          if (busy) return;
          busy = true;
          try {
            await job.run();
          } catch (error, stackTrace) {
            _log.severe('Job ${job.name} failed', error, stackTrace);
          } finally {
            busy = false;
          }
        }),
      );
    }
  }

  void stop() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }
}
