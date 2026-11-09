/// Lifecycle states of the `host_setup` aggregates.
library;

/// The states of the `calendar_connection` lifecycle.
enum CalendarConnectionLifecycleState {
  /// `connected`: path `main`, end: false.
  connected,

  /// `connecting`: path `main`, end: false.
  connecting,

  /// `connection_failed`: path `failure`, end: false.
  connectionFailed,
}

/// The states of the `availability_schedule` lifecycle.
enum AvailabilityScheduleLifecycleState {
  /// `defined`: path `main`, end: false.
  defined,
}

/// The states of the `meeting_type` lifecycle.
enum MeetingTypeLifecycleState {
  /// `active`: path `main`, end: false.
  active,

  /// `deleted`: path `cancel`, end: true.
  deleted,

  /// `disabled`: path `main`, end: false.
  disabled,
}
