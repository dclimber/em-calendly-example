import 'package:jaspr/server.dart';

import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../repository.dart';
import 'slot_list.dart';

/// The page where a participant of a meeting picks a new time for it. The meeting's own slot is not counted as busy,
/// and the meeting type's booking switch does not apply.
final class RescheduleSlotPickerPage extends AsyncStatelessComponent {
  const RescheduleSlotPickerPage({
    required this.repository,
    required this.meetingId,
    required this.viewerId,
    required this.now,
    super.key,
  });

  final AvailableSlotsRepository repository;
  final String meetingId;
  final String viewerId;
  final DateTime now;

  @override
  Future<Component> build(BuildContext context) async {
    final state = await repository.ofMeeting(meetingId);
    final meeting = state?.meetings[meetingId];
    if (state == null || meeting == null) return const EmptyState('This meeting does not exist.');
    if (viewerId != state.hostId && viewerId != meeting.bookerId) {
      return const EmptyState('Only the participants of this meeting can move it.');
    }

    final title = state.meetingTypes[meeting.meetingTypeId]?.title ?? '';
    final slots = state.slotsOf(meeting.meetingTypeId, now, exceptMeetingId: meetingId).items;
    return Panel(
      title: title,
      children: [
        if (slots.isEmpty)
          const EmptyState('No other times are available.')
        else
          SlotList(
            slots: slots,
            hrefFor: (slot) => confirmNewSlot(meetingId, slot.startAt, slot.endAt),
          ),
      ],
    );
  }
}
