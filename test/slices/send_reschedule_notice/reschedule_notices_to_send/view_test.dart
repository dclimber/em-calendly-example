import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/send_reschedule_notice/reschedule_notices_to_send/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  final reserved = reservedEvent();

  // @requires a completed reschedule: a meeting_reschedule_requested event and then its meeting_rescheduled event
  // @ensures scenario completed_reschedule_waits_for_announcement: the item is listed, ready, with the new slot
  test('completed_reschedule_waits_for_announcement', () {
    final v = rescheduleNoticesToSendView;
    final state = v.evolve(v.evolve(v.initialState, rescheduleRequested()), rescheduled());
    expect(state, isNotNull);
    expect(state!.ready, isTrue);
    expect(state.meetingId, reserved.meetingId);
    expect(state.newSlotStart, NewSlotStart(rescheduleStart));
    expect(state.newSlotEnd, NewSlotEnd(rescheduleEnd));
    expect(state.participants, reserved.participants);
  });

  // @requires a reschedule that is requested but not completed
  // @ensures the item is kept with the new slot but not ready, so it is not listed to announce
  test('a requested reschedule alone is not announced', () {
    final v = rescheduleNoticesToSendView;
    final state = v.evolve(v.evolve(v.initialState, reserved), rescheduleRequested());
    expect(state, isNotNull);
    expect(state!.ready, isFalse);
    expect(state.meetingTitle, reserved.meetingTitle);
  });

  // @requires a completed reschedule whose reschedule_notice_sent event is folded
  // @ensures scenario announced_reschedule_leaves_the_list: the item is no longer ready, so it is not listed
  test('announced_reschedule_leaves_the_list', () {
    final v = rescheduleNoticesToSendView;
    final done = v.evolve(v.evolve(v.evolve(v.initialState, reserved), rescheduleRequested()), rescheduled());
    final state = v.evolve(done, noticeSent());
    expect(state, isNotNull);
    expect(state!.ready, isFalse);
  });

  // @requires a meeting_slot_reserved event, then a meeting_moved_in_calendar event with no reschedule request
  // @ensures scenario direct_move_is_announced: the item is ready with the moved time
  test('direct_move_is_announced', () {
    final v = rescheduleNoticesToSendView;
    final state = v.evolve(v.evolve(v.initialState, reserved), movedInCalendar());
    expect(state, isNotNull);
    expect(state!.ready, isTrue);
    expect(state.newSlotStart, NewSlotStart(DateTime.utc(2027, 3, 15, 11)));
    expect(state.newSlotEnd, NewSlotEnd(DateTime.utc(2027, 3, 15, 11, 30)));
    expect(state.meetingTitle, reserved.meetingTitle);
  });

  // @requires a meeting_slot_reserved event alone (the booking itself is not a reschedule)
  // @ensures the reservation opens an item that is not ready, so no notice is sent for a first booking
  test('a reservation alone is not announced', () {
    final v = rescheduleNoticesToSendView;
    final state = v.evolve(v.initialState, reserved);
    expect(state, isNotNull);
    expect(state!.ready, isFalse);
  });

  // @requires a notice that was sent, then a later reschedule to another time
  // @ensures the later reschedule replaces the new slot and is ready again, with the title kept
  test('a later reschedule replaces the announced time', () {
    final v = rescheduleNoticesToSendView;
    final done = v.evolve(v.evolve(v.evolve(v.initialState, reserved), rescheduleRequested()), rescheduled());
    final announced = v.evolve(done, noticeSent());
    final later = rescheduleRequested(start: DateTime.utc(2027, 3, 15, 12), end: DateTime.utc(2027, 3, 15, 12, 30));
    final state = v.evolve(v.evolve(announced, later), rescheduled());
    expect(state!.ready, isTrue);
    expect(state.newSlotStart, NewSlotStart(DateTime.utc(2027, 3, 15, 12)));
    expect(state.meetingTitle, reserved.meetingTitle);
  });

  // @requires a meeting_rescheduled event with no reschedule request folded before it
  // @ensures the completion opens no item: the state stays null
  test('a completion without a request opens no item', () {
    final v = rescheduleNoticesToSendView;
    expect(v.evolve(v.initialState, rescheduled()), isNull);
  });

  // @requires a ready item whose reservation is delivered again
  // @ensures the redelivered reservation keeps the ready flag and the new slot: a redelivery never undoes a reschedule
  test('a redelivered reservation keeps the ready item and its new slot', () {
    final v = rescheduleNoticesToSendView;
    final ready = v.evolve(v.evolve(v.initialState, reserved), movedInCalendar());
    final again = v.evolve(ready, reserved);
    expect(again!.ready, isTrue);
    expect(again.newSlotStart, ready!.newSlotStart);
  });

  // @requires the same events folded twice
  // @ensures law: folding a repeated event yields the same item (idempotent per event)
  test('law: a repeated reschedule event yields the same item', () {
    final v = rescheduleNoticesToSendView;
    final once = v.evolve(v.evolve(v.initialState, reserved), rescheduleRequested());
    expect(v.evolve(once, rescheduleRequested()), equals(once));
  });
}
