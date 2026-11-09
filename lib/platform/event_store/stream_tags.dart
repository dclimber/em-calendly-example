import '../../bounded_contexts/event_contract.dart';

/// The tags of an event: its own [own] tags, then each tag of the first event of its stream ([stream]) whose name
/// the event does not carry itself.
///
/// A meeting never changes its host, so `MeetingConfirmedEvent` (which holds only `meetingId`) is found by
/// `hostId` too.
List<EventTag> withStreamTags(List<EventTag> own, List<EventTag> stream) {
  final names = {for (final t in own) t.tag};
  return [...own, ...stream.where((t) => !names.contains(t.tag))];
}
