import 'package:fmodel/fmodel.dart';

import 'record_busy_times/command.dart';
import 'reported_free_busy/state.dart';

/// The processor `free_busy_translator`: a reported free/busy answer records the host's busy intervals. It maps the
/// read-model state to one `record_busy_times` command.
final freeBusyTranslatorSaga = saga<ReportedFreeBusyState, RecordBusyTimesCommand>((reported) async* {
  yield RecordBusyTimesCommand(hostId: reported.hostId, busyIntervals: reported.busyIntervals);
});
