import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// Lifecycle states in which a meeting cannot be canceled.
const _endedStates = {
  MeetingLifecycleState.canceled,
  MeetingLifecycleState.completed,
  MeetingLifecycleState.bookingFailed,
};

/// Lifecycle states in which another change to the meeting is still running.
const _inChangeStates = {
  MeetingLifecycleState.pendingCalendar,
  MeetingLifecycleState.rescheduling,
  MeetingLifecycleState.canceling,
};

final requestMeetingCancellationDecider = Decider<RequestMeetingCancellationCommand, CancellationState, DomainEvent>(
  initialState: const CancellationState(),
  decide: (command, state) async* {
    final meetingId = command.meetingId.value;
    final booking = state.bookings[meetingId];
    final requester = command.requestedBy.value;
    final isParticipant = booking != null && booking.participants.items.any((p) => p.employeeId.value == requester);
    if (booking == null || !isParticipant) throw const NotAParticipantError();

    final lifecycle = state.lifecycles[meetingId];
    if (_endedStates.contains(lifecycle)) throw const MeetingEndedError();
    if (_inChangeStates.contains(lifecycle)) throw const ChangeInProgressError();
    if (lifecycle != MeetingLifecycleState.confirmed) {
      throw StateError('A meeting in state $lifecycle has no transition to cancel.');
    }

    final calendarEventId = booking.calendarEventId;
    if (calendarEventId == null) throw StateError('A confirmed meeting has a calendar event.');

    yield MeetingCancellationRequestedEvent(
      meetingId: command.meetingId,
      hostId: booking.hostId,
      requestedBy: command.requestedBy,
      calendarEventId: CalendarEventId(calendarEventId),
      participants: booking.participants,
    );
  },
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent(:final meetingId, :final hostId, :final participants) => state.copyWith(
      bookings: {
        ...state.bookings,
        meetingId.value: CancellableBooking(hostId: hostId, participants: participants),
      },
      lifecycles: {...state.lifecycles, meetingId.value: MeetingLifecycleState.pendingCalendar},
    ),
    MeetingConfirmedEvent(:final meetingId, :final calendarEventId) => _withBooking(
      state,
      meetingId.value,
      MeetingLifecycleState.confirmed,
      calendarEventId: calendarEventId.value,
    ),
    MeetingBookingFailedEvent(:final meetingId) => _withLifecycle(
      state,
      meetingId.value,
      MeetingLifecycleState.bookingFailed,
    ),
    MeetingRescheduleRequestedEvent(:final meetingId) => _withLifecycle(
      state,
      meetingId.value,
      MeetingLifecycleState.rescheduling,
    ),
    MeetingRescheduledEvent(:final meetingId) => _withLifecycle(
      state,
      meetingId.value,
      MeetingLifecycleState.confirmed,
    ),
    MeetingRescheduleFailedEvent(:final meetingId) => _withLifecycle(
      state,
      meetingId.value,
      MeetingLifecycleState.confirmed,
    ),
    MeetingCancellationRequestedEvent(:final meetingId) => _withLifecycle(
      state,
      meetingId.value,
      MeetingLifecycleState.canceling,
    ),
    MeetingCancellationFailedEvent(:final meetingId) => _withLifecycle(
      state,
      meetingId.value,
      MeetingLifecycleState.confirmed,
    ),
    MeetingCanceledEvent(:final meetingId) => _withLifecycle(state, meetingId.value, MeetingLifecycleState.canceled),
    MeetingCompletedEvent(:final meetingId) => _withLifecycle(state, meetingId.value, MeetingLifecycleState.completed),
    _ => state,
  },
);

CancellationState _withLifecycle(CancellationState state, String meetingId, MeetingLifecycleState lifecycle) =>
    state.copyWith(lifecycles: {...state.lifecycles, meetingId: lifecycle});

CancellationState _withBooking(
  CancellationState state,
  String meetingId,
  MeetingLifecycleState lifecycle, {
  required String calendarEventId,
}) {
  final booking = state.bookings[meetingId];
  return state.copyWith(
    bookings: booking == null
        ? state.bookings
        : {...state.bookings, meetingId: booking.copyWith(calendarEventId: calendarEventId)},
    lifecycles: {...state.lifecycles, meetingId: lifecycle},
  );
}
