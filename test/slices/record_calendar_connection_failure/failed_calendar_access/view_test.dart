import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/record_calendar_connection_failure/failed_calendar_access/state.dart';
import 'package:em_calendly_example/slices/record_calendar_connection_failure/failed_calendar_access/view.dart';
import 'package:test/test.dart';

void main() {
  final failure = CalendarAccessFailedEvent(
    failureCode: FailureCode('token_revoked'),
    schedulerUserRef: SchedulerUserRef('alice-employee-id'),
  );

  // @requires an empty history of calendar access failures
  // @ensures scenario empty_history: the view has no failed access
  test('empty_history', () {
    expect(failedCalendarAccessView.initialState, isNull);
  });

  // @requires one calendar_access_failed event
  // @ensures scenario failure_is_listed: the view holds the host and the failure code of the event
  test('failure_is_listed', () {
    final state = failedCalendarAccessView.evolve(failedCalendarAccessView.initialState, failure);
    expect(
      state,
      FailedCalendarAccessState(
        hostId: HostId('alice-employee-id'),
        connectionFailure: ConnectionFailure('token_revoked'),
      ),
    );
  });

  // @requires any calendar_access_failed event
  // @ensures the view names the host of the scheduler user ref, and the failure code as the connection failure
  test('maps the scheduler user ref and the failure code', () {
    for (final (ref, code) in [('alice-employee-id', 'token_revoked'), ('bob-employee-id', 'timeout')]) {
      final state = failedCalendarAccessView.evolve(
        failedCalendarAccessView.initialState,
        CalendarAccessFailedEvent(failureCode: FailureCode(code), schedulerUserRef: SchedulerUserRef(ref)),
      );
      expect(state?.hostId, HostId(ref));
      expect(state?.connectionFailure, ConnectionFailure(code));
    }
  });
}
