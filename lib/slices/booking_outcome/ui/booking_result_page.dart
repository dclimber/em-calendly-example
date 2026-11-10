import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/meetings/api.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../service.dart';
import '../state.dart';

/// The page that tells a booker whether the booking was confirmed, and if not, why. While the view has no document yet,
/// the page says the booking is being confirmed. Only the booker of the meeting sees its outcome.
final class BookingResultPage extends AsyncStatelessComponent {
  const BookingResultPage({required this.service, required this.meetingId, required this.viewerId, super.key});

  final BookingOutcomeService service;
  final MeetingId meetingId;
  final String viewerId;

  @override
  Future<Component> build(BuildContext context) async {
    final outcome = await service.outcomeOf(meetingId);
    if (outcome == null || outcome.meetingStatus == BookingStatus.pending) {
      return Panel(
        title: 'Booking',
        children: [
          const EmptyState('Your booking is being confirmed.'),
          LinkButton(href: bookingResult(meetingId.value), label: 'Reload'),
        ],
      );
    }
    if (outcome.bookerId.value != viewerId) {
      return const Panel(title: 'Booking', children: [EmptyState('You cannot see this booking.')]);
    }
    if (outcome.meetingStatus == BookingStatus.failed) {
      return Panel(
        title: 'Booking failed',
        children: [
          p([Component.text(outcome.failureReason?.value ?? 'The booking failed.')]),
          LinkButton(href: bookingPage(outcome.meetingTypeId.value), label: 'Choose another time', primary: true),
        ],
      );
    }
    return Panel(
      title: 'Booking confirmed',
      children: [
        Facts([
          ('Meeting', Component.text(outcome.meetingTitle.value)),
          ('Time', _time(outcome)),
          ('Location', Component.text(outcome.meetingLocation.value)),
        ]),
        LinkButton(href: meetingDetails(meetingId.value), label: 'Open meeting details'),
      ],
    );
  }

  static Component _time(BookingOutcome outcome) => span([
    LocalTime(iso: outcome.slotStart.value.toUtc().toIso8601String()),
    Component.text(' to '),
    LocalTime(iso: outcome.slotEnd.value.toUtc().toIso8601String(), timeOnly: true),
  ]);
}
