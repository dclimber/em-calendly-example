import '../slices/record_calendar_connected/module.dart';
import '../slices/fail_booking/module.dart';
import '../slices/available_slots/module.dart';
import '../slices/reserve_meeting_slot/module.dart';
import '../slices/request_booking_availability_check/module.dart';
import '../slices/verify_booked_slot/module.dart';
import '../slices/request_calendar_event/module.dart';
import '../slices/confirm_booked_meeting/module.dart';
import '../slices/calendar_connection_status/module.dart';
import '../slices/record_host_busy_times/module.dart';
import '../slices/create_availability_schedule/module.dart';
import '../slices/record_calendar_connection_failure/module.dart';
import '../slices/register_employee_on_first_sign_in/module.dart';
import '../slices/start_calendar_connection/module.dart';
import '../slices/set_weekly_hours/module.dart';
import '../slices/set_booking_limits/module.dart';
import '../slices/add_date_exception/module.dart';
import '../slices/change_date_exception/module.dart';
import '../slices/remove_date_exception/module.dart';
import '../slices/my_availability_schedules/module.dart';
import '../slices/create_meeting_type/module.dart';
import '../slices/my_meeting_types/module.dart';
import '../slices/edit_meeting_type/module.dart';
import '../slices/disable_meeting_type/module.dart';
import '../slices/enable_meeting_type/module.dart';
import '../slices/delete_meeting_type/module.dart';
import '../slices/booking_outcome/module.dart';
import '../slices/send_booking_confirmation/module.dart';
import '../slices/hosted_meetings/module.dart';
import '../slices/my_booked_meetings/module.dart';
import '../slices/meeting_details/module.dart';
import '../slices/request_meeting_reschedule/module.dart';
import '../slices/request_reschedule_availability_check/module.dart';
import '../slices/verify_rescheduled_slot/module.dart';
import '../slices/request_calendar_event_update/module.dart';
import '../slices/complete_meeting_reschedule/module.dart';
import '../slices/fail_meeting_reschedule/module.dart';
import '../slices/apply_direct_calendar_move/module.dart';
import '../slices/send_reschedule_notice/module.dart';
import '../slices/request_meeting_cancellation/module.dart';
import '../slices/request_calendar_event_deletion/module.dart';
import '../slices/complete_meeting_cancellation/module.dart';
import '../slices/fail_meeting_cancellation/module.dart';
import '../slices/apply_direct_calendar_deletion/module.dart';
import '../slices/send_cancellation_notice/module.dart';
import 'vertical_slice.dart';

/// Every slice of the model, in board order. Each new slice adds its import and its `module.dart` instance here.
const List<VerticalSlice> verticalSlices = [
  RegisterEmployeeOnFirstSignInSlice(),
  StartCalendarConnectionSlice(),
  RecordCalendarConnectedSlice(),
  RecordCalendarConnectionFailureSlice(),
  CalendarConnectionStatusSlice(),
  RecordHostBusyTimesSlice(),
  CreateAvailabilityScheduleSlice(),
  SetWeeklyHoursSlice(),
  SetBookingLimitsSlice(),
  AddDateExceptionSlice(),
  ChangeDateExceptionSlice(),
  RemoveDateExceptionSlice(),
  MyAvailabilitySchedulesSlice(),
  CreateMeetingTypeSlice(),
  MyMeetingTypesSlice(),
  EditMeetingTypeSlice(),
  DisableMeetingTypeSlice(),
  EnableMeetingTypeSlice(),
  DeleteMeetingTypeSlice(),
  AvailableSlotsSlice(),
  ReserveMeetingSlotSlice(),
  RequestBookingAvailabilityCheckSlice(),
  VerifyBookedSlotSlice(),
  RequestCalendarEventSlice(),
  ConfirmBookedMeetingSlice(),
  FailBookingSlice(),
  BookingOutcomeSlice(),
  SendBookingConfirmationSlice(),
  HostedMeetingsSlice(),
  MyBookedMeetingsSlice(),
  MeetingDetailsSlice(),
  RequestMeetingRescheduleSlice(),
  RequestRescheduleAvailabilityCheckSlice(),
  VerifyRescheduledSlotSlice(),
  RequestCalendarEventUpdateSlice(),
  CompleteMeetingRescheduleSlice(),
  FailMeetingRescheduleSlice(),
  ApplyDirectCalendarMoveSlice(),
  SendRescheduleNoticeSlice(),
  RequestMeetingCancellationSlice(),
  RequestCalendarEventDeletionSlice(),
  CompleteMeetingCancellationSlice(),
  FailMeetingCancellationSlice(),
  ApplyDirectCalendarDeletionSlice(),
  SendCancellationNoticeSlice(),
];
