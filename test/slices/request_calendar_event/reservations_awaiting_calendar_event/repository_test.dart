import 'package:em_calendly_example/platform/view_store/in_memory_view_state_store.dart';
import 'package:em_calendly_example/slices/request_calendar_event/reservations_awaiting_calendar_event/repository.dart';
import 'package:em_calendly_example/slices/request_calendar_event/reservations_awaiting_calendar_event/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  final repository = ReservationsAwaitingCalendarEventRepository(InMemoryViewStateStore());

  // @requires any listed or unlisted held slot, with participants
  // @ensures the document codec is lossless: decoding an encoded state gives back an equal state
  test('the document codec round-trips every state', () {
    final reserved = reservedEvent();
    final states = [
      ReservationAwaitingCalendarEventState(
        meetingId: reserved.meetingId,
        hostId: reserved.hostId,
        meetingTitle: reserved.meetingTitle,
        meetingLocation: reserved.meetingLocation,
        slotStart: reserved.slotStart,
        slotEnd: reserved.slotEnd,
        participants: reserved.participants,
      ),
      ReservationAwaitingCalendarEventState(
        meetingId: reserved.meetingId,
        hostId: reserved.hostId,
        meetingTitle: reserved.meetingTitle,
        meetingLocation: reserved.meetingLocation,
        slotStart: reserved.slotStart,
        slotEnd: reserved.slotEnd,
        participants: reserved.participants,
        verified: true,
      ),
    ];
    for (final state in states) {
      expect(repository.decodeState(repository.encodeState(state)), state);
    }
  });
}
