import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/calendar_connection_status/state.dart';
import 'package:em_calendly_example/slices/calendar_connection_status/view.dart';
import 'package:test/test.dart';

import '../../support/samples/host_setup_samples.dart';

final _alice = HostId('alice-employee-id');

CalendarConnectionStatus _state(ConnectionStatus status, {CalendarAccount? account, ConnectionFailure? failure}) =>
    CalendarConnectionStatus(
      hostId: _alice,
      connectionStatus: status,
      calendarAccount: account,
      connectionFailure: failure,
    );

CalendarConnectionStatus? _fold(List<HostSetupEvent> events) => events.fold<CalendarConnectionStatus?>(
  calendarConnectionStatusView.initialState,
  calendarConnectionStatusView.evolve,
);

void main() {
  final started = CalendarConnectionStartedEvent(hostId: _alice);
  final connected = CalendarConnectedEvent(hostId: _alice, calendarAccount: CalendarAccount('alice@example.com'));
  final failed = CalendarConnectionFailedEvent(
    hostId: _alice,
    connectionFailure: ConnectionFailure('Consent was denied'),
  );

  group('appear', () {
    // @requires the host starts a connection and the calendar gets connected
    // @ensures the read model shows the connected calendar
    test('connected_calendar_is_shown', () {
      expect(
        _fold([started, connected]),
        _state(ConnectionStatus.connected, account: CalendarAccount('alice@example.com')),
      );
    });
  });

  group('change', () {
    // @requires the calendar is connected, and then the connection fails
    // @ensures the read model shows the failure, and the connected calendar is no longer shown
    test('connection_failure_is_visible', () {
      expect(
        _fold([connected, failed]),
        _state(ConnectionStatus.failed, failure: ConnectionFailure('Consent was denied')),
      );
    });
  });

  // @requires the host has no connection event yet
  // @ensures the read model has no document (null)
  test('no_connection_yet', () {
    expect(_fold(const []), isNull);
  });

  // @requires the connection has started and has not finished
  // @ensures the read model shows the connecting status without a calendar or a failure
  test('started_connection_is_connecting', () {
    expect(_fold([started]), _state(ConnectionStatus.connecting));
  });

  // @requires any event of the view's readmodel.from, in any order
  // @ensures the latest event decides, so a retry after a failure shows connecting
  test('retry_after_failure_is_connecting', () {
    expect(_fold([failed, started]), _state(ConnectionStatus.connecting));
  });

  // @requires given is the scenario event list
  // @ensures fold(initialState, given) == then
  test('fold of given events yields then read model', () {
    final given = [started, connected];
    expect(
      given.fold(calendarConnectionStatusView.initialState, calendarConnectionStatusView.evolve),
      _state(ConnectionStatus.connected, account: CalendarAccount('alice@example.com')),
    );
  });

  // @requires event is not consumed by the view (any host setup event but the three connection events)
  // @ensures evolve(s, event) == s
  test('ignores events it does not consume', () {
    final states = [
      null,
      _state(ConnectionStatus.connecting),
      _state(ConnectionStatus.connected, account: CalendarAccount('alice@example.com')),
      _state(ConnectionStatus.failed, failure: ConnectionFailure('Consent was denied')),
    ];
    final unconsumed = sampleHostSetupEvents().where(
      (e) =>
          e is! CalendarConnectionStartedEvent && e is! CalendarConnectedEvent && e is! CalendarConnectionFailedEvent,
    );
    expect(unconsumed, isNotEmpty);
    for (final state in states) {
      for (final event in unconsumed) {
        expect(calendarConnectionStatusView.evolve(state, event), state);
      }
    }
  });

  // @requires the state round-trips through its JSON document
  // @ensures fromJson(toJson(s)) == s for every state of the view
  test('state JSON round trip', () {
    final states = [
      _state(ConnectionStatus.connecting),
      _state(ConnectionStatus.connected, account: CalendarAccount('alice@example.com')),
      _state(ConnectionStatus.failed, failure: ConnectionFailure('Consent was denied')),
    ];
    for (final state in states) {
      expect(CalendarConnectionStatus.fromJson(state.toJson()), state);
    }
  });
}
