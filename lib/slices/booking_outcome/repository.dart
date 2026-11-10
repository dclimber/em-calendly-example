import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/event_store.dart';
import '../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `booking_outcome`: one document per meeting id.
final class BookingOutcomeRepository extends DocumentViewStateRepository<BookingOutcome> {
  BookingOutcomeRepository(super.store);

  @override
  String get viewName => 'booking_outcome';

  @override
  String? keyOf(StoredEvent event) => switch (event.event) {
    MeetingSlotReservedEvent(:final meetingId) => meetingId.value,
    MeetingConfirmedEvent(:final meetingId) => meetingId.value,
    MeetingBookingFailedEvent(:final meetingId) => meetingId.value,
    _ => null,
  };

  @override
  String keyOfState(BookingOutcome state) => state.meetingId.value;

  @override
  Map<String, Object?> encodeState(BookingOutcome state) => state.toJson();

  @override
  BookingOutcome decodeState(Map<String, Object?> json) => BookingOutcome.fromJson(json);
}
