import 'package:fmodel/fmodel.dart';

import 'free_answers_for_bookings/state.dart';
import 'record_booking_slot_verified/command.dart';

/// The processor `booking_free_translator`: each listed free answer yields one `record_booking_slot_verified` command
/// for its meeting.
final bookingFreeTranslatorSaga = saga<FreeAnswerForBookingState, RecordBookingSlotVerifiedCommand>(
  (item) async* {
    yield RecordBookingSlotVerifiedCommand(meetingId: item.meetingId);
  },
);
