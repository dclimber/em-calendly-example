import '../../../bounded_contexts/corporate_calendar/api.dart';
import '../../../bounded_contexts/meetings/api.dart';

/// A busy answer gives 'This time is no longer available. Please choose another slot.' A failed check gives 'The host's
/// availability cannot be verified right now. Please try again later.' A refused calendar change keeps its failure code.
///
/// Returns null for any event that is not one of the three negative answers.
FailureReason? failureReasonOf(CorporateCalendarEvent answer) => switch (answer) {
  HostSlotFoundBusyEvent() => FailureReason('This time is no longer available. Please choose another slot.'),
  AvailabilityCheckFailedEvent() => FailureReason(
    "The host's availability cannot be verified right now. Please try again later.",
  ),
  CalendarEventUpdateFailedEvent(:final failureCode) => FailureReason(failureCode.value),
  _ => null,
};
