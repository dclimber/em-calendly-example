import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/booking_outcome/state.dart';
import 'package:em_calendly_example/slices/booking_outcome/view.dart';
import 'package:test/test.dart';

import '../../support/samples/meetings_samples.dart';

final _reserved = sampleMeetingsEvents().whereType<MeetingSlotReservedEvent>().single;
final _confirmed = sampleMeetingsEvents().whereType<MeetingConfirmedEvent>().single;
final _failed = sampleMeetingsEvents().whereType<MeetingBookingFailedEvent>().single;

final _meetingId = MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766');

BookingOutcome _pending() => BookingOutcome(
  meetingId: _meetingId,
  bookerId: BookerId('bob-employee-id'),
  meetingTypeId: MeetingTypeId('e3b5aceb-a393-5517-acf5-fb11936414a5'),
  meetingTitle: MeetingTitle('30-minute consultation'),
  meetingLocation: MeetingLocation('Video call'),
  slotStart: SlotStart(DateTime.utc(2026, 11, 16, 9, 0)),
  slotEnd: SlotEnd(DateTime.utc(2026, 11, 16, 9, 30)),
  meetingStatus: BookingStatus.pending,
);

BookingOutcome? _fold(List<MeetingsEvent> events) =>
    events.fold<BookingOutcome?>(bookingOutcomeView.initialState, bookingOutcomeView.evolve);

void main() {
  // @requires a meeting slot was reserved for bob
  // @ensures the read model shows the booking as pending, with its title, slot, and no failure reason
  test('reserved_booking_is_pending', () {
    expect(_fold([_reserved]), equals(_pending()));
  });

  // @requires a meeting slot was reserved and the calendar confirmed it
  // @ensures the read model shows the booking as confirmed, with the same details
  test('confirmed_booking_is_shown', () {
    final state = _fold([_reserved, _confirmed]);

    expect(state, isNotNull);
    expect(state!.meetingStatus, BookingStatus.confirmed);
    expect(state.failureReason, isNull);
    expect(state.meetingTitle, _pending().meetingTitle);
  });

  // @requires a meeting slot was reserved and the booking then failed
  // @ensures the read model shows the booking as failed, with the reason
  test('failed_booking_shows_why', () {
    final state = _fold([_reserved, _failed]);

    expect(state, isNotNull);
    expect(state!.meetingStatus, BookingStatus.failed);
    expect(state.failureReason, _failed.failureReason);
  });

  // @requires a confirmation or a failure arrives before any reservation
  // @ensures the view has no document, so nothing changes
  test('outcome before the reservation changes nothing', () {
    expect(_fold([_confirmed]), isNull);
    expect(_fold([_failed]), isNull);
  });

  // @requires a meeting slot was reserved
  // @ensures events the view does not consume leave the document unchanged
  test('events that do not change the outcome leave it unchanged', () {
    final others = sampleMeetingsEvents().where(
      (event) =>
          event is! MeetingSlotReservedEvent && event is! MeetingConfirmedEvent && event is! MeetingBookingFailedEvent,
    );
    expect(_fold([_reserved, ...others]), equals(_pending()));
  });
}
