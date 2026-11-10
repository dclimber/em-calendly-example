import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/send_cancellation_notice/cancellation_notices_to_send/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  final reserved = reservedEvent();
  final v = cancellationNoticesToSendView;

  // @requires a canceled meeting: the reservation, the cancellation requested, and meeting_canceled
  // @ensures scenario canceled_meeting_waits_for_announcement: the item is listed, ready, with title, slot, and participants
  test('canceled_meeting_waits_for_announcement', () {
    final state = [reserved, cancellationRequested(), canceled()].fold(v.initialState, v.evolve);
    expect(state, isNotNull);
    expect(state!.ready, isTrue);
    expect(state.meetingId, reserved.meetingId);
    expect(state.meetingTitle, MeetingTitle('Intro call'));
    expect(state.slotStart, reserved.slotStart);
    expect(state.slotEnd, reserved.slotEnd);
    expect(state.participants, reserved.participants);
  });

  // @requires a meeting that is confirmed and not canceled
  // @ensures the item is kept but not ready, so it is not listed to announce
  test('a confirmed meeting is not announced', () {
    final state = [reserved, confirmedEvent()].fold(v.initialState, v.evolve);
    expect(state, isNotNull);
    expect(state!.ready, isFalse);
  });

  // @requires a canceled meeting whose cancellation_notice_sent was recorded
  // @ensures scenario announced_cancellation_leaves_the_list: the item is not ready
  test('announced_cancellation_leaves_the_list', () {
    final state = [reserved, cancellationRequested(), canceled(), noticeSent()].fold(v.initialState, v.evolve);
    expect(state, isNotNull);
    expect(state!.ready, isFalse);
  });

  // @requires a direct deletion: the reservation then meeting_canceled, with no cancellation_requested
  // @ensures scenario direct_deletion_is_announced: the item is listed, ready
  test('direct_deletion_is_announced', () {
    final state = [reserved, canceled()].fold(v.initialState, v.evolve);
    expect(state!.ready, isTrue);
    expect(state.participants, reserved.participants);
  });

  // @requires a meeting_canceled event for a meeting with no reservation
  // @ensures the event changes nothing: no item is created without the reservation
  test('a cancellation without a reservation creates no item', () {
    expect(v.evolve(v.initialState, canceled()), isNull);
  });

  // @requires any canceled meeting
  // @ensures law idempotence: folding meeting_canceled twice gives the same item as folding it once
  test('law: a repeated meeting_canceled gives the same item', () {
    final once = [reserved, canceled()].fold(v.initialState, v.evolve);
    final twice = [reserved, canceled(), canceled()].fold(v.initialState, v.evolve);
    expect(twice, once);
  });

  // @requires a listed item
  // @ensures law: the notice clears the ready flag and keeps the title and slot
  test('law: the notice keeps the title and slot and clears the ready flag', () {
    final before = [reserved, canceled()].fold(v.initialState, v.evolve);
    final after = v.evolve(before, noticeSent());
    expect(after!.ready, isFalse);
    expect(after.meetingTitle, before!.meetingTitle);
    expect(after.slotStart, before.slotStart);
    expect(after.slotEnd, before.slotEnd);
  });
}
