import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../ui/kit.dart';
import '../../../ui/paths.dart';

/// Shows the chosen slot and asks the booker to confirm it. The form posts the slot back as hidden fields.
class ReviewBookingPage extends StatelessComponent {
  const ReviewBookingPage({required this.meetingTypeId, required this.start, required this.end, super.key});

  final String meetingTypeId;
  final DateTime? start;
  final DateTime? end;

  @override
  Component build(BuildContext context) {
    final start = this.start;
    final end = this.end;
    if (start == null || end == null) {
      return const EmptyState('This slot is not valid. Please choose another slot.');
    }
    return Panel(
      title: 'Review your booking',
      children: [
        p([Component.text('Starts: ${start.toIso8601String()}')]),
        p([Component.text('Ends: ${end.toIso8601String()}')]),
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
