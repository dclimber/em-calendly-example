import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';

/// The facts of one booked meeting that a cancellation decides on, from its `meeting_slot_reserved` and
/// `meeting_confirmed`.
final class CancellableBooking {
  const CancellableBooking({required this.hostId, required this.participants, this.calendarEventId});

  final HostId hostId;
  final Participants participants;

  /// Set by `meeting_confirmed`; null while the meeting is pending in the calendar.
  final String? calendarEventId;

  CancellableBooking copyWith({String? calendarEventId}) => CancellableBooking(
    hostId: hostId,
    participants: participants,
    calendarEventId: calendarEventId ?? this.calendarEventId,
  );
}

/// The state that `request_meeting_cancellation` decides on, folded from the meeting's own stream only.
final class CancellationState {
  const CancellationState({this.bookings = const {}, this.lifecycles = const {}});

  /// The booked facts by meeting id.
  final Map<String, CancellableBooking> bookings;

  /// The lifecycle state by meeting id.
  final Map<String, MeetingLifecycleState> lifecycles;

  CancellationState copyWith({
    Map<String, CancellableBooking>? bookings,
    Map<String, MeetingLifecycleState>? lifecycles,
  }) => CancellationState(bookings: bookings ?? this.bookings, lifecycles: lifecycles ?? this.lifecycles);
}
