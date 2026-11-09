import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/record_calendar_connected/granted_calendar_access/state.dart';
import 'package:em_calendly_example/slices/record_calendar_connected/saga.dart';
import 'package:test/test.dart';

final _granted = GrantedCalendarAccessState(
  hostId: HostId('alice-employee-id'),
  calendarAccount: CalendarAccount('alice@example.com'),
);

void main() {
  // @requires a granted calendar access for a host
  // @ensures scenario grant_connects_the_calendar: the processor emits one record_calendar_connected command
  test('grant_connects_the_calendar', () async {
    final commands = await connectionTranslatorSaga.react(_granted).toList();
    expect(commands.single.hostId, _granted.hostId);
    expect(commands.single.calendarAccount, _granted.calendarAccount);
  });

  // @requires any granted calendar access
  // @ensures the processor emits exactly one command that names the same host and account
  test('exactly one command per grant', () async {
    final grants = [
      _granted,
      GrantedCalendarAccessState(
        hostId: HostId('bob-employee-id'),
        calendarAccount: CalendarAccount('bob@example.com'),
      ),
    ];
    for (final granted in grants) {
      final commands = await connectionTranslatorSaga.react(granted).toList();
      expect(commands, hasLength(1));
      expect(commands.single.hostId, granted.hostId);
      expect(commands.single.calendarAccount, granted.calendarAccount);
    }
  });
}
