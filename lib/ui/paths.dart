/// The URL of every screen of the model, so slices link to each other's screens without importing each other.
///
/// `*Route` values are shelf_router patterns for registration. The functions build concrete links.
/// A form posts to the same path as its page unless a separate `*Action` is given.
library;

// ---- Sign in and connect calendar ----

/// screen.view_calendar_connection.calendar_connection
const calendarRoute = '/calendar';

/// screen.start_calendar_connection.connect_calendar (a button on the calendar page)
const connectCalendarAction = '/calendar/connect';

// ---- Configure availability ----

/// screen.view_availability_schedules.availability_schedules
const schedulesRoute = '/schedules';

/// screen.create_availability_schedule.new_availability_schedule (form posts to [schedulesRoute])
const newScheduleRoute = '/schedules/new';

/// screen.set_weekly_hours.edit_weekly_hours
const weeklyHoursRoute = '/schedules/<scheduleId>/weekly-hours';
String weeklyHours(String scheduleId) => '/schedules/$scheduleId/weekly-hours';

/// screen.add_date_exception.add_exception (form posts to [dateExceptionsAction])
const newDateExceptionRoute = '/schedules/<scheduleId>/exceptions/new';
String newDateException(String scheduleId) => '/schedules/$scheduleId/exceptions/new';
const dateExceptionsActionRoute = '/schedules/<scheduleId>/exceptions';
String dateExceptionsAction(String scheduleId) => '/schedules/$scheduleId/exceptions';

/// screen.change_date_exception.change_exception. [date] is `yyyy-MM-dd`.
const changeDateExceptionRoute = '/schedules/<scheduleId>/exceptions/<date>';
String changeDateException(String scheduleId, String date) => '/schedules/$scheduleId/exceptions/$date';

/// screen.remove_date_exception.remove_exception (a button)
const removeDateExceptionRoute = '/schedules/<scheduleId>/exceptions/<date>/remove';
String removeDateException(String scheduleId, String date) => '/schedules/$scheduleId/exceptions/$date/remove';

/// screen.set_booking_limits.edit_booking_limits
const bookingLimitsRoute = '/schedules/<scheduleId>/limits';
String bookingLimits(String scheduleId) => '/schedules/$scheduleId/limits';

// ---- Publish meeting types ----

/// screen.view_my_meeting_types.meeting_types
const meetingTypesRoute = '/meeting-types';

/// screen.create_meeting_type.new_meeting_type (form posts to [meetingTypesRoute])
const newMeetingTypeRoute = '/meeting-types/new';

/// screen.edit_meeting_type.edit_meeting_type_form
const editMeetingTypeRoute = '/meeting-types/<meetingTypeId>/edit';
String editMeetingType(String meetingTypeId) => '/meeting-types/$meetingTypeId/edit';

/// screen.disable_meeting_type.disable_meeting_type_action (a button)
const disableMeetingTypeRoute = '/meeting-types/<meetingTypeId>/disable';
String disableMeetingType(String meetingTypeId) => '/meeting-types/$meetingTypeId/disable';

/// screen.enable_meeting_type.enable_meeting_type_action (a button)
const enableMeetingTypeRoute = '/meeting-types/<meetingTypeId>/enable';
String enableMeetingType(String meetingTypeId) => '/meeting-types/$meetingTypeId/enable';

/// screen.delete_meeting_type.delete_meeting_type_action (a button)
const deleteMeetingTypeRoute = '/meeting-types/<meetingTypeId>/delete';
String deleteMeetingType(String meetingTypeId) => '/meeting-types/$meetingTypeId/delete';

// ---- Book a meeting ----

/// screen.view_available_slots.booking_page. This is the `booking_url` of a meeting type.
const bookingPageRoute = '/book/<meetingTypeId>';
String bookingPage(String meetingTypeId) => '/book/$meetingTypeId';

/// screen.reserve_meeting_slot.review_booking. Query: `start`, `end` (ISO-8601 UTC). The form posts to the same
/// path.
const reviewBookingRoute = '/book/<meetingTypeId>/review';
String reviewBooking(String meetingTypeId, DateTime start, DateTime end) => Uri(
  path: '/book/$meetingTypeId/review',
  queryParameters: {'start': start.toUtc().toIso8601String(), 'end': end.toUtc().toIso8601String()},
).toString();

/// screen.view_booking_outcome.booking_result
const bookingResultRoute = '/bookings/<meetingId>';
String bookingResult(String meetingId) => '/bookings/$meetingId';

// ---- View scheduled meetings ----

/// screen.view_hosted_meetings.hosted_meetings
const hostedMeetingsRoute = '/meetings/hosted';

/// screen.view_my_booked_meetings.my_booked_meetings
const bookedMeetingsRoute = '/meetings/booked';

/// screen.view_meeting_details.meeting_details
const meetingDetailsRoute = '/meetings/<meetingId>';
String meetingDetails(String meetingId) => '/meetings/$meetingId';

// ---- Reschedule a meeting ----

/// screen.view_available_slots.reschedule_slot_picker
const rescheduleSlotPickerRoute = '/meetings/<meetingId>/reschedule';
String rescheduleSlotPicker(String meetingId) => '/meetings/$meetingId/reschedule';

/// screen.request_meeting_reschedule.confirm_new_slot. Query: `start`, `end`. The form posts to the same path.
const confirmNewSlotRoute = '/meetings/<meetingId>/reschedule/confirm';
String confirmNewSlot(String meetingId, DateTime start, DateTime end) => Uri(
  path: '/meetings/$meetingId/reschedule/confirm',
  queryParameters: {'start': start.toUtc().toIso8601String(), 'end': end.toUtc().toIso8601String()},
).toString();

// ---- Cancel or complete a meeting ----

/// screen.request_meeting_cancellation.confirm_cancellation. The form posts to the same path.
const confirmCancellationRoute = '/meetings/<meetingId>/cancel';
String confirmCancellation(String meetingId) => '/meetings/$meetingId/cancel';

// ---- Platform ----

const homeRoute = '/';
const signInRoute = '/sign-in';
const signUpRoute = '/sign-up';
const signOutRoute = '/sign-out';
const devCalendarRoute = '/dev/calendar';
