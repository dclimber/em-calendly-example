import '../../../bounded_contexts/meetings/api.dart';

/// Sends the booking confirmation of a confirmed meeting (`send_booking_confirmation`). Sent by the processor
/// `confirmation_sender` for an item of `confirmations_to_send`.
final class SendBookingConfirmationCommand {
  const SendBookingConfirmationCommand({required this.meetingId, required this.participants});

  final MeetingId meetingId;
  final Participants participants;

  @override
  bool operator ==(Object other) =>
      other is SendBookingConfirmationCommand && other.meetingId == meetingId && other.participants == participants;

  @override
  int get hashCode => Object.hash(meetingId, participants);

  @override
  String toString() => 'SendBookingConfirmationCommand(meetingId: $meetingId, participants: $participants)';
}
