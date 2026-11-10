import 'package:jaspr/server.dart';

import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../repository.dart';
import 'slot_list.dart';

/// The booking page of one meeting type: its details and the slots a booker can take. It offers no slots while the
/// meeting type is not accepting bookings.
final class BookingPage extends AsyncStatelessComponent {
  const BookingPage({required this.repository, required this.meetingTypeId, required this.now, super.key});

  final AvailableSlotsRepository repository;
  final String meetingTypeId;
  final DateTime now;

  @override
  Future<Component> build(BuildContext context) async {
    final state = await repository.ofMeetingType(meetingTypeId);
    final meetingType = state?.meetingTypes[meetingTypeId];
    if (state == null || meetingType == null) return const EmptyState('This meeting type does not exist.');
    if (!meetingType.accepting) return const EmptyState('This meeting type is not accepting bookings.');

    final slots = state.slotsOf(meetingTypeId, now).items;
    return Panel(
      title: meetingType.title,
      children: [
        Facts([
          ('Host', Component.text(state.hostName)),
          ('Duration', Component.text('${meetingType.durationMinutes} min')),
          ('Location', Component.text(meetingType.location)),
          if (meetingType.description case final description?) ('About', Component.text(description)),
        ]),
        if (slots.isEmpty)
          const EmptyState('No times are available.')
        else
          SlotList(
            slots: slots,
            hrefFor: (slot) => reviewBooking(meetingTypeId, slot.startAt, slot.endAt),
          ),
      ],
    );
  }
}
