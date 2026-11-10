import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/booking_outcome/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/samples/meetings_samples.dart';
import '../../support/test_app.dart';

final _reserved = sampleMeetingsEvents().whereType<MeetingSlotReservedEvent>().single;
final _confirmed = sampleMeetingsEvents().whereType<MeetingConfirmedEvent>().single;
final _failed = sampleMeetingsEvents().whereType<MeetingBookingFailedEvent>().single;

const _meetingId = 'f1d91c85-3a90-593b-9d5e-7cb450033766';
const _meetingTypeId = 'e3b5aceb-a393-5517-acf5-fb11936414a5';

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(slices: const [BookingOutcomeSlice()]);
    await t.start();
  });

  // @requires bob reserved a slot and the calendar has not answered yet
  // @ensures bob's page says the booking is being confirmed and offers a reload
  test('reserved slot: the page says the booking is being confirmed', () async {
    await t.given([_reserved]);
    await t.drain();
    final response = await t.get(bookingResult(_meetingId), as: bob);

    expect(response.statusCode, 200);
    expect(response.body, contains('Your booking is being confirmed.'));
    expect(response.body, contains(bookingResult(_meetingId)));
  });

  // @requires the page is opened before any reservation exists
  // @ensures the page says the booking is being confirmed, not an error
  test('no document yet: the page says the booking is being confirmed', () async {
    final response = await t.get(bookingResult(_meetingId), as: bob);

    expect(response.statusCode, 200);
    expect(response.body, contains('Your booking is being confirmed.'));
  });

  // @requires the calendar confirmed bob's booking
  // @ensures the page shows the title, the time, the location, and a link to the meeting details
  test('confirmed booking: the page shows the meeting and its details', () async {
    await t.given([_reserved, _confirmed]);
    await t.drain();
    final response = await t.get(bookingResult(_meetingId), as: bob);

    expect(response.body, contains('Booking confirmed'));
    expect(response.body, contains('30-minute consultation'));
    expect(response.body, contains('Video call'));
    expect(response.body, contains('<time'));
    expect(response.body, contains(meetingDetails(_meetingId)));
  });

  // @requires the booking failed after the slot was reserved
  // @ensures the page shows the reason and offers to choose another time with the same meeting type
  test('failed booking: the page shows why and links to another time', () async {
    await t.given([_reserved, _failed]);
    await t.drain();
    final response = await t.get(bookingResult(_meetingId), as: bob);

    expect(response.body, contains('Booking failed'));
    expect(response.body, contains('The host is busy at that time'));
    expect(response.body, contains(bookingPage(_meetingTypeId)));
    expect(response.body, contains('Choose another time'));
  });

  // @requires alice is not the booker of the meeting
  // @ensures alice cannot see the outcome, the meeting title is not shown
  test('another employee cannot see the booking outcome', () async {
    await t.given([_reserved, _confirmed]);
    await t.drain();
    final response = await t.get(bookingResult(_meetingId), as: alice);

    expect(response.body, contains('You cannot see this booking.'));
    expect(response.body, isNot(contains('30-minute consultation')));
  });
}
