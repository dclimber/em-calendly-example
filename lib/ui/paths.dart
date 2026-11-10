/// The URL of every screen of the model, so slices link to each other's screens without importing each other.
///
/// `*Route` values are shelf_router patterns for registration. The functions build concrete links.
/// A form posts to the same path as its page unless a separate `*Action` is given.
library;

/// The prefix of every screen of the application. `/` is the public landing page.
const appRoot = '/app';

// ---- Sign in and connect calendar ----

/// screen.view_calendar_connection.calendar_connection
const calendarRoute = '$appRoot/calendar';

/// screen.start_calendar_connection.connect_calendar (a button on the calendar page)
const connectCalendarAction = '$appRoot/calendar/connect';

// ---- Configure availability ----

/// screen.view_availability_schedules.availability_schedules
const schedulesRoute = '$appRoot/schedules';

/// screen.create_availability_schedule.new_availability_schedule (form posts to [schedulesRoute])
const newScheduleRoute = '$appRoot/schedules/new';

/// screen.set_weekly_hours.edit_weekly_hours
const weeklyHoursRoute = '$appRoot/schedules/<scheduleId>/weekly-hours';
String weeklyHours(String scheduleId) => '$appRoot/schedules/$scheduleId/weekly-hours';

/// screen.add_date_exception.add_exception (form posts to [dateExceptionsAction])
const newDateExceptionRoute = '$appRoot/schedules/<scheduleId>/exceptions/new';
String newDateException(String scheduleId) => '$appRoot/schedules/$scheduleId/exceptions/new';
const dateExceptionsActionRoute = '$appRoot/schedules/<scheduleId>/exceptions';
String dateExceptionsAction(String scheduleId) => '$appRoot/schedules/$scheduleId/exceptions';

/// screen.change_date_exception.change_exception. [date] is `yyyy-MM-dd`.
const changeDateExceptionRoute = '$appRoot/schedules/<scheduleId>/exceptions/<date>';
String changeDateException(String scheduleId, String date) => '$appRoot/schedules/$scheduleId/exceptions/$date';

/// screen.remove_date_exception.remove_exception (a button)
const removeDateExceptionRoute = '$appRoot/schedules/<scheduleId>/exceptions/<date>/remove';
String removeDateException(String scheduleId, String date) => '$appRoot/schedules/$scheduleId/exceptions/$date/remove';

/// screen.set_booking_limits.edit_booking_limits
const bookingLimitsRoute = '$appRoot/schedules/<scheduleId>/limits';
String bookingLimits(String scheduleId) => '$appRoot/schedules/$scheduleId/limits';

// ---- Publish meeting types ----

/// screen.view_my_meeting_types.meeting_types
const meetingTypesRoute = '$appRoot/meeting-types';

/// screen.create_meeting_type.new_meeting_type (form posts to [meetingTypesRoute])
const newMeetingTypeRoute = '$appRoot/meeting-types/new';

/// screen.edit_meeting_type.edit_meeting_type_form
const editMeetingTypeRoute = '$appRoot/meeting-types/<meetingTypeId>/edit';
String editMeetingType(String meetingTypeId) => '$appRoot/meeting-types/$meetingTypeId/edit';

/// screen.disable_meeting_type.disable_meeting_type_action (a button)
const disableMeetingTypeRoute = '$appRoot/meeting-types/<meetingTypeId>/disable';
String disableMeetingType(String meetingTypeId) => '$appRoot/meeting-types/$meetingTypeId/disable';

/// screen.enable_meeting_type.enable_meeting_type_action (a button)
const enableMeetingTypeRoute = '$appRoot/meeting-types/<meetingTypeId>/enable';
String enableMeetingType(String meetingTypeId) => '$appRoot/meeting-types/$meetingTypeId/enable';

/// screen.delete_meeting_type.delete_meeting_type_action (a button)
const deleteMeetingTypeRoute = '$appRoot/meeting-types/<meetingTypeId>/delete';
String deleteMeetingType(String meetingTypeId) => '$appRoot/meeting-types/$meetingTypeId/delete';

// ---- Book a meeting ----

/// screen.view_available_slots.booking_page. This is the `booking_url` of a meeting type.
const bookingPageRoute = '$appRoot/book/<meetingTypeId>';
String bookingPage(String meetingTypeId) => '$appRoot/book/$meetingTypeId';

/// screen.reserve_meeting_slot.review_booking. Query: `start`, `end` (ISO-8601 UTC). The form posts to the same
/// path.
const reviewBookingRoute = '$appRoot/book/<meetingTypeId>/review';
String reviewBooking(String meetingTypeId, DateTime start, DateTime end) => Uri(
  path: '$appRoot/book/$meetingTypeId/review',
  queryParameters: {'start': start.toUtc().toIso8601String(), 'end': end.toUtc().toIso8601String()},
).toString();

/// screen.view_booking_outcome.booking_result
const bookingResultRoute = '$appRoot/bookings/<meetingId>';
String bookingResult(String meetingId) => '$appRoot/bookings/$meetingId';

// ---- View scheduled meetings ----

/// screen.view_hosted_meetings.hosted_meetings
const hostedMeetingsRoute = '$appRoot/meetings/hosted';

/// screen.view_my_booked_meetings.my_booked_meetings
const bookedMeetingsRoute = '$appRoot/meetings/booked';

/// screen.view_meeting_details.meeting_details
const meetingDetailsRoute = '$appRoot/meetings/<meetingId>';
String meetingDetails(String meetingId) => '$appRoot/meetings/$meetingId';

// ---- Reschedule a meeting ----

/// screen.view_available_slots.reschedule_slot_picker
const rescheduleSlotPickerRoute = '$appRoot/meetings/<meetingId>/reschedule';
String rescheduleSlotPicker(String meetingId) => '$appRoot/meetings/$meetingId/reschedule';

/// screen.request_meeting_reschedule.confirm_new_slot. Query: `start`, `end`. The form posts to the same path.
const confirmNewSlotRoute = '$appRoot/meetings/<meetingId>/reschedule/confirm';
String confirmNewSlot(String meetingId, DateTime start, DateTime end) => Uri(
  path: '$appRoot/meetings/$meetingId/reschedule/confirm',
  queryParameters: {'start': start.toUtc().toIso8601String(), 'end': end.toUtc().toIso8601String()},
).toString();

// ---- Cancel or complete a meeting ----

/// screen.request_meeting_cancellation.confirm_cancellation. The form posts to the same path.
const confirmCancellationRoute = '$appRoot/meetings/<meetingId>/cancel';
String confirmCancellation(String meetingId) => '$appRoot/meetings/$meetingId/cancel';

// ---- Platform ----

/// The public landing page: what the app does and the event model behind it. It needs no session.
const landingRoute = '/';

/// The interactive diagram of the event model, rendered by `emhcl diagram` into `web/` (see the Makefile).
const eventModelDiagramPath = '/event-model.html';

const homeRoute = appRoot;
const signInRoute = '$appRoot/sign-in';
const signUpRoute = '$appRoot/sign-up';
const signOutRoute = '$appRoot/sign-out';
const devCalendarRoute = '$appRoot/dev/calendar';
