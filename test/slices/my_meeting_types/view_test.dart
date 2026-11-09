import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/my_meeting_types/state.dart';
import 'package:em_calendly_example/slices/my_meeting_types/view.dart';
import 'package:test/test.dart';

import '../../support/samples/host_setup_samples.dart';

final _meetingType = MeetingTypeId('mt-1');
final _alice = HostId('alice-employee-id');
const _url = 'https://scheduler.example.com/book/mt-1';

final _created = MeetingTypeCreatedEvent(
  meetingTypeId: _meetingType,
  hostId: _alice,
  meetingTitle: MeetingTitle('30-minute consultation'),
  durationMinutes: DurationMinutes(30),
  meetingLocation: MeetingLocation('Video call'),
  scheduleId: ScheduleId('sched-1'),
  bookingUrl: BookingUrl(_url),
);
final _edited = MeetingTypeEditedEvent(
  meetingTypeId: _meetingType,
  meetingTitle: MeetingTitle('45-minute review'),
  durationMinutes: DurationMinutes(45),
  meetingLocation: MeetingLocation('Room 4'),
  scheduleId: ScheduleId('sched-1'),
);
final _disabled = MeetingTypeDisabledEvent(meetingTypeId: _meetingType);
final _enabled = MeetingTypeEnabledEvent(meetingTypeId: _meetingType);
final _deleted = MeetingTypeDeletedEvent(meetingTypeId: _meetingType);

MyMeetingType? _fold(List<HostSetupEvent> events) =>
    events.fold<MyMeetingType?>(myMeetingTypesView.initialState, myMeetingTypesView.evolve);

MyMeetingType _plain({bool active = true, String title = '30-minute consultation', int minutes = 30}) => MyMeetingType(
  meetingTypeId: _meetingType,
  hostId: _alice,
  meetingTitle: MeetingTitle(title),
  durationMinutes: DurationMinutes(minutes),
  meetingLocation: MeetingLocation(title == '30-minute consultation' ? 'Video call' : 'Room 4'),
  bookingUrl: BookingUrl(_url),
  active: active,
);

void main() {
  // @requires no meeting type has been created
  // @ensures the view has no meeting type yet
  test('no meeting type yet: the view is empty', () {
    expect(_fold([]), isNull);
  });

  // @requires alice created a meeting type
  // @ensures the view lists it as active with its booking link
  test('new meeting type has a link: created sets the details and the booking url, active', () {
    expect(_fold([_created]), _plain());
  });

  // @requires alice created a meeting type, then edited it
  // @ensures the details change, and the booking link and the active flag stay the same
  test('edit keeps the booking link: edited changes the details and keeps the url', () {
    final state = _fold([_created, _edited])!;
    expect(state.meetingTitle.value, '45-minute review');
    expect(state.durationMinutes.value, 45);
    expect(state.meetingLocation.value, 'Room 4');
    expect(state.bookingUrl.value, _url);
    expect(state.active, isTrue);
  });

  // @requires alice created a meeting type, then disabled it
  // @ensures the view marks it inactive
  test('disabled meeting type is marked inactive', () {
    expect(_fold([_created, _disabled])!.active, isFalse);
  });

  // @requires alice disabled a meeting type, then enabled it
  // @ensures the view marks it active again
  test('enabled meeting type is marked active again', () {
    expect(_fold([_created, _disabled, _enabled])!.active, isTrue);
  });

  // @requires alice created a meeting type, then deleted it
  // @ensures the view no longer holds the meeting type
  test('deleted meeting type disappears', () {
    expect(_fold([_created, _deleted]), isNull);
  });

  // @requires events of a meeting type arrive before it was created
  // @ensures they change nothing
  test('events before creation change nothing', () {
    expect(_fold([_edited, _disabled, _enabled, _deleted]), isNull);
  });

  // @requires any sequence of events for one meeting type
  // @ensures folding the same events twice gives the same state
  test('folding is deterministic', () {
    expect(_fold([_created, _disabled, _edited]), _fold([_created, _disabled, _edited]));
  });

  // @requires an event that belongs to another slice
  // @ensures the view ignores it
  test('ignores events of other slices', () {
    final unrelated = sampleHostSetupEvents()
        .where((e) => e is! MeetingTypeCreatedEvent && e is! MeetingTypeEditedEvent)
        .where((e) => e is! MeetingTypeDisabledEvent && e is! MeetingTypeEnabledEvent)
        .where((e) => e is! MeetingTypeDeletedEvent)
        .toList();
    expect(_fold([_created, ...unrelated]), _plain());
  });

  // @requires a meeting type state
  // @ensures it survives a JSON round trip
  test('state round-trips through JSON', () {
    final state = _plain(active: false);
    expect(MyMeetingType.fromJson(state.toJson()), state);
  });
}
