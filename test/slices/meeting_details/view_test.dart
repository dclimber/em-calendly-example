import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/meeting_details/state.dart';
import 'package:em_calendly_example/slices/meeting_details/view.dart';
import 'package:test/test.dart';

import '../../support/samples/meetings_samples.dart';

final _reserved = sampleMeetingsEvents().whereType<MeetingSlotReservedEvent>().single;
final _confirmed = sampleMeetingsEvents().whereType<MeetingConfirmedEvent>().single;
final _rescheduleRequested = sampleMeetingsEvents().whereType<MeetingRescheduleRequestedEvent>().single;
final _rescheduleFailed = sampleMeetingsEvents().whereType<MeetingRescheduleFailedEvent>().single;
final _rescheduled = sampleMeetingsEvents().whereType<MeetingRescheduledEvent>().single;
final _moved = sampleMeetingsEvents().whereType<MeetingMovedInCalendarEvent>().single;
final _cancellationRequested = sampleMeetingsEvents().whereType<MeetingCancellationRequestedEvent>().single;
final _cancellationFailed = sampleMeetingsEvents().whereType<MeetingCancellationFailedEvent>().single;
final _canceled = sampleMeetingsEvents().whereType<MeetingCanceledEvent>().single;
final _completed = sampleMeetingsEvents().whereType<MeetingCompletedEvent>().single;

MeetingDetails? _fold(List<MeetingsEvent> events) =>
    events.fold<MeetingDetails?>(meetingDetailsView.initialState, meetingDetailsView.evolve);

void main() {
  // @requires no meeting has been reserved
  // @ensures the view has no document, so the page says the meeting is not available yet
  test('empty_history: no document', () {
    expect(_fold([]), isNull);
  });

  // @requires a slot was reserved and then confirmed
  // @ensures the document is active, with the reserved slot, the participants, and the calendar event id
  test('confirmed_meeting_details_appear', () {
    final state = _fold([_reserved, _confirmed]);

    expect(state, isNotNull);
    expect(state!.status, MeetingDetailsStatus.active);
    expect(state.canChange, isTrue);
    expect(state.meetingTitle, _reserved.meetingTitle);
    expect(state.meetingLocation, _reserved.meetingLocation);
    expect(state.meetingTypeId, _reserved.meetingTypeId);
    expect(state.slotStart, _reserved.slotStart);
    expect(state.slotEnd, _reserved.slotEnd);
    expect(state.participants, _reserved.participants);
    expect(state.calendarEventId, _confirmed.calendarEventId);
    expect(state.failureReason, isNull);
  });

  // @requires a confirmed meeting whose reschedule was requested and then failed
  // @ensures the status is active again, the original slot stays, and the failure reason is shown
  test('failed_reschedule_keeps_the_original_time', () {
    final state = _fold([_reserved, _confirmed, _rescheduleRequested, _rescheduleFailed]);

    expect(state!.status, MeetingDetailsStatus.active);
    expect(state.slotStart, _reserved.slotStart);
    expect(state.slotEnd, _reserved.slotEnd);
    expect(state.requestedSlotStart, isNull);
    expect(state.failureReason, _rescheduleFailed.failureReason);
  });

  // @requires a confirmed meeting whose cancellation was requested and then failed
  // @ensures the meeting stays active with the failure reason
  test('failed_cancellation_keeps_the_meeting', () {
    final state = _fold([_reserved, _confirmed, _cancellationRequested, _cancellationFailed]);

    expect(state!.status, MeetingDetailsStatus.active);
    expect(state.failureReason, _cancellationFailed.failureReason);
  });

  // @requires a confirmed meeting that was moved directly in the calendar
  // @ensures the document shows the new slot and is active
  test('direct_move_shows_the_new_time', () {
    final state = _fold([_reserved, _confirmed, _moved]);

    expect(state!.status, MeetingDetailsStatus.active);
    expect(state.slotStart.value, _moved.newSlotStart.value);
    expect(state.slotEnd.value, _moved.newSlotEnd.value);
  });

  // @requires a reschedule was requested and not yet completed
  // @ensures the status is change in progress and the action links are hidden
  test('change_in_progress_blocks_changes', () {
    final state = _fold([_reserved, _confirmed, _rescheduleRequested]);

    expect(state!.status, MeetingDetailsStatus.changeInProgress);
    expect(state.canChange, isFalse);
    expect(state.slotStart, _reserved.slotStart);
    expect(state.requestedSlotStart!.value.toUtc(), _rescheduleRequested.newSlotStart.value.toUtc());
  });

  // @requires a reschedule was requested and completed
  // @ensures the slot of the reschedule is the meeting's slot and the status is active
  test('completed_reschedule_takes_the_requested_slot', () {
    final state = _fold([_reserved, _confirmed, _rescheduleRequested, _rescheduled]);

    expect(state!.status, MeetingDetailsStatus.active);
    expect(state.slotStart.value.toUtc(), _rescheduleRequested.newSlotStart.value.toUtc());
    expect(state.requestedSlotStart, isNull);
  });

  // @requires a cancellation was requested and completed
  // @ensures the status is canceled
  test('canceled_meeting_is_canceled', () {
    final state = _fold([_reserved, _confirmed, _cancellationRequested, _canceled]);

    expect(state!.status, MeetingDetailsStatus.canceled);
    expect(state.canChange, isFalse);
  });

  // @requires a confirmed meeting has ended
  // @ensures the status is completed
  test('completed_meeting_is_completed', () {
    final state = _fold([_reserved, _confirmed, _completed]);

    expect(state!.status, MeetingDetailsStatus.completed);
  });

  // Laws
  // @requires any history of the sample meeting
  // @ensures a reserved meeting without confirmation has no status, so it never shows as active
  test('law: a reservation alone has no status', () {
    final state = _fold([_reserved]);

    expect(state!.status, isNull);
    expect(state.canChange, isFalse);
    expect(state.isLive, isFalse);
  });

  // @requires a meeting that was canceled
  // @ensures no later change event revives it
  test('law: a canceled meeting stays canceled', () {
    final ended = _fold([_reserved, _confirmed, _cancellationRequested, _canceled]);
    final after = _fold([
      _reserved,
      _confirmed,
      _cancellationRequested,
      _canceled,
      _rescheduleRequested,
      _rescheduled,
      _completed,
    ]);

    expect(after!.status, MeetingDetailsStatus.canceled);
    expect(after, ended);
  });

  // @requires a reserved meeting
  // @ensures the participant ids are exactly the ids of the reserved participants
  test('law: participant ids are the reserved participants', () {
    final state = _fold([_reserved, _confirmed]);

    expect(state!.participantIds.toList(), _reserved.participants.items.map((p) => p.employeeId).toList());
  });
}
