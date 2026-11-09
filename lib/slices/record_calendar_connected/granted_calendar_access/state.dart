import '../../../bounded_contexts/host_setup/api.dart';

/// One calendar access that the calendar system granted. `hostId` is the host id that the scheduler user ref names.
final class GrantedCalendarAccessState {
  const GrantedCalendarAccessState({required this.hostId, required this.calendarAccount});

  final HostId hostId;
  final CalendarAccount calendarAccount;

  @override
  bool operator ==(Object other) =>
      other is GrantedCalendarAccessState && other.hostId == hostId && other.calendarAccount == calendarAccount;

  @override
  int get hashCode => Object.hash(hostId, calendarAccount);

  @override
  String toString() => 'GrantedCalendarAccessState(hostId: $hostId, calendarAccount: $calendarAccount)';
}
