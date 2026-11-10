import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/employee_directory/api.dart';
import '../../../bounded_contexts/host_setup/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';

/// The meeting facts that the review shows: the latest values of the meeting type, and its host's name.
final class ReviewedMeeting {
  const ReviewedMeeting({
    required this.title,
    required this.location,
    required this.durationMinutes,
    required this.hostName,
  });

  final String title;
  final String location;
  final int durationMinutes;
  final String hostName;
}

/// Reads the review facts of [meetingTypeId], or null when the meeting type was never created.
Future<ReviewedMeeting?> reviewedMeetingFor(EventStore store, String meetingTypeId) async {
  final read = await store.read([
    (
      tag: 'meetingTypeId',
      value: meetingTypeId,
      eventTypes: const [MeetingTypeCreatedEvent, MeetingTypeEditedEvent],
    ),
  ]);
  final events = read.events.map((stored) => stored.event).toList();
  final created = events.whereType<MeetingTypeCreatedEvent>().firstOrNull;
  if (created == null) return null;
  final latest = events.last;
  final (title, location, duration) = switch (latest) {
    MeetingTypeCreatedEvent(:final meetingTitle, :final meetingLocation, :final durationMinutes) => (
      meetingTitle.value,
      meetingLocation.value,
      durationMinutes.value,
    ),
    MeetingTypeEditedEvent(:final meetingTitle, :final meetingLocation, :final durationMinutes) => (
      meetingTitle.value,
      meetingLocation.value,
      durationMinutes.value,
    ),
    _ => throw StateError('unreachable: the query returns only created and edited events'),
  };
  final hostName = await _hostNameFor(store, created.hostId.value);
  return ReviewedMeeting(title: title, location: location, durationMinutes: duration, hostName: hostName);
}

Future<String> _hostNameFor(EventStore store, String hostId) async {
  final read = await store.read([
    (tag: 'employeeId', value: hostId, eventTypes: const [EmployeeRegisteredEvent]),
  ]);
  final registered = read.events.map((stored) => stored.event).whereType<EmployeeRegisteredEvent>().lastOrNull;
  return registered?.employeeName.value ?? hostId;
}

/// Shows the meeting and the chosen slot, and asks the booker to confirm it. The form posts the slot back as hidden
/// fields.
final class ReviewBookingPage extends AsyncStatelessComponent {
  const ReviewBookingPage({
    required this.eventStore,
    required this.meetingTypeId,
    required this.start,
    required this.end,
    super.key,
  });

  final EventStore eventStore;
  final String meetingTypeId;
  final DateTime? start;
  final DateTime? end;

  @override
  Future<Component> build(BuildContext context) async {
    final start = this.start;
    final end = this.end;
    if (start == null || end == null) {
      return const EmptyState('This slot is not valid. Please choose another slot.');
    }
    final meeting = await reviewedMeetingFor(eventStore, meetingTypeId);
    if (meeting == null) {
      return const EmptyState('This slot is not valid. Please choose another slot.');
    }
    return Panel(
      title: 'Review your booking',
      children: [
        Facts([
          ('Meeting', Component.text(meeting.title)),
          ('Host', Component.text(meeting.hostName)),
          ('Duration', Component.text('${meeting.durationMinutes} minutes')),
          ('Location', Component.text(meeting.location)),
          ('Starts', LocalTime(iso: start.toIso8601String())),
          ('Ends', LocalTime(iso: end.toIso8601String())),
        ]),
        PostForm(
          action: reviewBooking(meetingTypeId, start, end),
          submitLabel: 'Confirm booking',
          children: [
            input(type: InputType.hidden, name: 'start', value: start.toIso8601String()),
            input(type: InputType.hidden, name: 'end', value: end.toIso8601String()),
          ],
        ),
      ],
    );
  }
}
