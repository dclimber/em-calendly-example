/// Value objects of the `corporate_calendar` bounded context.
library;

/// The `scheduler_user_ref` field type (String).
extension type const SchedulerUserRef._(String value) {
  factory SchedulerUserRef(String value) => SchedulerUserRef._(value);
}

/// The `scheduler_meeting_ref` field type (String).
extension type const SchedulerMeetingRef._(String value) {
  factory SchedulerMeetingRef(String value) => SchedulerMeetingRef._(value);
}

/// The `failure_code` field type (String).
extension type const FailureCode._(String value) {
  factory FailureCode(String value) => FailureCode._(value);
}

/// One entry of the `free_busy_blocks` field type.
final class FreeBusyBlock {
  const FreeBusyBlock({required this.busyFrom, required this.busyUntil});

  final DateTime busyFrom;
  final DateTime busyUntil;

  @override
  bool operator ==(Object other) =>
      other is FreeBusyBlock && other.busyFrom == busyFrom && other.busyUntil == busyUntil;

  @override
  int get hashCode => Object.hash(runtimeType, busyFrom, busyUntil);

  @override
  String toString() => 'FreeBusyBlock(busyFrom: $busyFrom, busyUntil: $busyUntil)';
}

/// The `free_busy_blocks` field type: a list of [FreeBusyBlock].
final class FreeBusyBlocks {
  FreeBusyBlocks(Iterable<FreeBusyBlock> items) : items = List.unmodifiable(items);

  /// An empty list.
  const FreeBusyBlocks.empty() : items = const [];

  final List<FreeBusyBlock> items;

  @override
  bool operator ==(Object other) {
    if (other is! FreeBusyBlocks || other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (other.items[i] != items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() => 'FreeBusyBlocks($items)';
}
