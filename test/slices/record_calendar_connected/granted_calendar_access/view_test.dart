import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/record_calendar_connected/granted_calendar_access/view.dart';
import 'package:test/test.dart';

final _granted = CalendarAccessGrantedEvent(
  schedulerUserRef: SchedulerUserRef('alice-employee-id'),
  calendarAccount: 'alice@example.com',
);

void main() {
  // @requires a calendar_access_granted event
  // @ensures scenario grant_is_listed: the view holds the host id and the calendar account of the grant
  test('grant_is_listed', () {
    final state = grantedCalendarAccessView.evolve(grantedCalendarAccessView.initialState, _granted);
    expect(state, isNotNull);
    expect(state!.hostId, HostId('alice-employee-id'));
    expect(state.calendarAccount, CalendarAccount('alice@example.com'));
  });

  // @requires no event
  // @ensures the view is empty before any grant
  test('empty before any grant', () {
    expect(grantedCalendarAccessView.initialState, isNull);
  });
}
