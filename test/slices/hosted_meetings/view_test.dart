import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/hosted_meetings/state.dart';
import 'package:em_calendly_example/slices/hosted_meetings/view.dart';
import 'package:test/test.dart';

import '../../support/samples/meetings_samples.dart';

final _reserved = sampleMeetingsEvents().whereType<MeetingSlotReservedEvent>().single;
final _confirmed = sampleMeetingsEvents().whereType<MeetingConfirmedEvent>().single;
final _failed = sampleMeetingsEvents().whereType<MeetingBookingFailedEvent>().single;
final _rescheduleRequested = sampleMeetingsEvents().whereType<MeetingRescheduleRequestedEvent>().single;
final _rescheduled = sampleMeetingsEvents().whereType<MeetingRescheduledEvent>().single;
final _moved = sampleMeetingsEvents().whereType<MeetingMovedInCalendarEvent>().single;
final _canceled = sampleMeetingsEvents().whereType<MeetingCanceledEvent>().single;
final _completed = sampleMeetingsEvents().whereType<MeetingCompletedEvent>().single;

HostedMeeting? _fold(List<MeetingsEvent> events) =>
    events.fold<HostedMeeting?>(hostedMeetingsView.initialState, hostedMeetingsView.evolve);

void main() {
  // @requires no meeting has been booked through the host's links
  // @ensures the view has no document, so the page lists nothing
  test('no_bookings_yet', () {
    expect(_fold([]), isNull);
  });

  // @requires a slot was reserved and the booking was confirmed
  // @ensures the document is active, with the reserved slot, title, and participants
  test('confirmed_meeting_is_active', () {
    final state = _fold([_reserved, _confirmed]);

    expect(state, isNotNull);
    expect(state!.meetingStatus, HostedMeetingStatus.active);
    expect(state.slotStart, _reserved.slotStart);
    expect(state.slotEnd, _reserved.slotEnd);
    expect(state.meetingTitle, _reserved.meetingTitle);
    expect(state.participants, _reserved.participants);
  });

  // @requires a slot was reserved and the booking then failed before any confirmation
  // @ensures the document exists but is not confirmed, so the page does not list it
  test('failed_booking_is_not_listed', () {
    final state = _fold([_reserved, _failed]);

    expect(state, isNotNull);
    expect(state!.isConfirmed, isFalse);
    expect(state.meetingStatus, isNull);
  });

  // @requires a confirmed meeting was canceled
  // @ensures the document is canceled
  test('canceled_meeting_is_marked_canceled', () {
    expect(_fold([_reserved, _confirmed, _canceled])!.meetingStatus, HostedMeetingStatus.canceled);
  });

  // @requires a confirmed meeting has finished
  // @ensures the document is completed
  test('finished_meeting_is_marked_completed', () {
    expect(_fold([_reserved, _confirmed, _completed])!.meetingStatus, HostedMeetingStatus.completed);
  });

  // @requires a confirmed meeting was rescheduled and the reschedule completed
  // @ensures the document shows the requested slot as its slot, and no requested slot remains
  test('rescheduled_meeting_shows_the_new_time', () {
    final state = _fold([_reserved, _confirmed, _rescheduleRequested, _rescheduled]);

    expect(state!.slotStart.value, _rescheduleRequested.newSlotStart.value);
    expect(state.slotEnd.value, _rescheduleRequested.newSlotEnd.value);
    expect(state.requestedSlotStart, isNull);
    expect(state.requestedSlotEnd, isNull);
    expect(state.meetingStatus, HostedMeetingStatus.active);
  });

  // @requires a reschedule was requested but not completed
  // @ensures the document keeps the reserved slot as the meeting time
  test('requested_reschedule_does_not_move_the_meeting_yet', () {
    final state = _fold([_reserved, _confirmed, _rescheduleRequested]);

    expect(state!.slotStart, _reserved.slotStart);
    expect(state.slotEnd, _reserved.slotEnd);
    expect(state.requestedSlotStart, isNotNull);
  });

  // @requires a confirmed meeting was moved directly in the calendar
  // @ensures the document shows the moved slot as its slot
  test('direct_move_shows_the_new_time', () {
    final state = _fold([_reserved, _confirmed, _moved]);

    expect(state!.slotStart.value, _moved.newSlotStart.value);
    expect(state.slotEnd.value, _moved.newSlotEnd.value);
    expect(state.meetingStatus, HostedMeetingStatus.active);
  });

  // @requires a slot was reserved, and then a cancel and a completion arrive before the confirmation
  // @ensures the document stays unconfirmed, so nothing is listed
  test('end_events_before_confirmation_change_nothing', () {
    final state = _fold([_reserved, _canceled, _completed]);

    expect(state!.isConfirmed, isFalse);
  });

  // @requires any event arrives before the reservation
  // @ensures the view has no document, so nothing changes
  test('events_before_the_reservation_change_nothing', () {
    expect(_fold([_confirmed, _canceled, _moved]), isNull);
  });

  // @requires any state the view builds from the samples
  // @ensures fromJson(toJson(state)) equals the state
  test('json_round_trip', () {
    final histories = [
      [_reserved],
      [_reserved, _confirmed],
      [_reserved, _confirmed, _rescheduleRequested],
      [_reserved, _confirmed, _rescheduleRequested, _rescheduled],
      [_reserved, _confirmed, _moved],
      [_reserved, _confirmed, _canceled],
      [_reserved, _confirmed, _completed],
    ];
    for (final history in histories) {
      final state = _fold(history)!;
      expect(HostedMeeting.fromJson(state.toJson()), state);
    }
  });

  // @requires the reserved slot and the booker of a meeting
  // @ensures the booker is the participant with the role booker
  test('booker is the participant with the booker role', () {
    expect(_fold([_reserved])!.booker?.name.value, 'Bob Example');
  });
}
