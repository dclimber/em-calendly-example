import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: its lifecycle state, and whether its booking confirmation was already sent.
final class SendBookingConfirmationState {
  const SendBookingConfirmationState({this.lifecycle, this.bookingConfirmationSent = false});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;
  final bool bookingConfirmationSent;

  @override
  bool operator ==(Object other) =>
      other is SendBookingConfirmationState &&
      other.lifecycle == lifecycle &&
      other.bookingConfirmationSent == bookingConfirmationSent;

  @override
  int get hashCode => Object.hash(lifecycle, bookingConfirmationSent);

  @override
  String toString() =>
      'SendBookingConfirmationState(lifecycle: $lifecycle, bookingConfirmationSent: $bookingConfirmationSent)';
}
