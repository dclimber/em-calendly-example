import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/record_calendar_connection_failure/failed_calendar_access/state.dart';
import 'package:em_calendly_example/slices/record_calendar_connection_failure/saga.dart';
import 'package:test/test.dart';

final _failed = FailedCalendarAccessState(
  hostId: HostId('alice-employee-id'),
  connectionFailure: ConnectionFailure('token_revoked'),
);

void main() {
  // @requires a failed calendar access for a host
  // @ensures the processor emits one record_connection_failure command with the same host and failure
  test('failure_is_translated_to_a_command', () async {
    final commands = await connectionFailureTranslatorSaga.react(_failed).toList();
    expect(commands.single.hostId, _failed.hostId);
    expect(commands.single.connectionFailure, _failed.connectionFailure);
  });

  // @requires any failed calendar access
  // @ensures the processor emits exactly one command that names the same host and failure
  test('exactly one command per failure', () async {
    final failures = [
      _failed,
      FailedCalendarAccessState(hostId: HostId('bob-employee-id'), connectionFailure: ConnectionFailure('timeout')),
    ];
    for (final failed in failures) {
      final commands = await connectionFailureTranslatorSaga.react(failed).toList();
      expect(commands, hasLength(1));
      expect(commands.single.hostId, failed.hostId);
      expect(commands.single.connectionFailure, failed.connectionFailure);
    }
  });
}
