/// Lifecycle states of the `meetings` aggregates.
library;

/// The states of the `meeting` lifecycle.
enum MeetingLifecycleState {
  /// `booking_failed`: path `failure`, end: true.
  bookingFailed,

  /// `canceled`: path `cancel`, end: true.
  canceled,

  /// `canceling`: path `cancel`, end: false.
  canceling,

  /// `completed`: path `main`, end: true.
  completed,

  /// `confirmed`: path `main`, end: false.
  confirmed,

  /// `pending_calendar`: path `main`, end: false.
  pendingCalendar,

  /// `rescheduling`: path `main`, end: false.
  rescheduling,
}
