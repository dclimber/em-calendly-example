/// One sample of every `host_setup` event.
library;

import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';

/// One instance of every `host_setup` event, with HCL example values where they exist.
List<HostSetupEvent> sampleHostSetupEvents() => [
  CalendarConnectionStartedEvent(hostId: HostId('alice-employee-id')),
  CalendarConnectedEvent(hostId: HostId('alice-employee-id'), calendarAccount: CalendarAccount('alice@example.com')),
  CalendarConnectionFailedEvent(
    hostId: HostId('alice-employee-id'),
    connectionFailure: ConnectionFailure('Consent was denied'),
  ),
  HostBusyTimesRecordedEvent(
    hostId: HostId('alice-employee-id'),
    busyIntervals: BusyIntervals([
      BusyInterval(busyFrom: DateTime.utc(2026, 11, 16, 9), busyUntil: DateTime.utc(2026, 11, 16, 10)),
      BusyInterval(busyFrom: DateTime.utc(2026, 11, 16, 13), busyUntil: DateTime.utc(2026, 11, 16, 14)),
    ]),
  ),
  AvailabilityScheduleCreatedEvent(
    scheduleId: ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423'),
    hostId: HostId('alice-employee-id'),
    scheduleName: ScheduleName('Working hours'),
    timeZone: TimeZone('Europe/Berlin'),
  ),
  WeeklyHoursSetEvent(
    scheduleId: ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423'),
    weeklyHours: WeeklyHours([
      WeeklyHoursEntry(weekday: 'monday', startTime: '09:00', endTime: '17:00'),
      WeeklyHoursEntry(weekday: 'friday', startTime: '09:00', endTime: '13:00'),
    ]),
  ),
  DateExceptionAddedEvent(
    scheduleId: ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423'),
    exceptionDate: ExceptionDate(DateTime.utc(2026, 12, 24)),
    exceptionHours: ExceptionHours([ExceptionHoursRange(startTime: '10:00', endTime: '12:00')]),
  ),
  DateExceptionChangedEvent(
    scheduleId: ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423'),
    exceptionDate: ExceptionDate(DateTime.utc(2026, 12, 24)),
    exceptionHours: const ExceptionHours.empty(),
  ),
  DateExceptionRemovedEvent(
    scheduleId: ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423'),
    exceptionDate: ExceptionDate(DateTime.utc(2026, 12, 24)),
  ),
  BookingLimitsSetEvent(
    scheduleId: ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423'),
    bookingWindowDays: BookingWindowDays(60),
    minimumNoticeMinutes: MinimumNoticeMinutes(240),
    bufferBeforeMinutes: BufferBeforeMinutes(5),
    bufferAfterMinutes: BufferAfterMinutes(10),
  ),
  MeetingTypeCreatedEvent(
    meetingTypeId: MeetingTypeId('e3b5aceb-a393-5517-acf5-fb11936414a5'),
    hostId: HostId('alice-employee-id'),
    meetingTitle: MeetingTitle('30-minute consultation'),
    durationMinutes: DurationMinutes(30),
    meetingLocation: MeetingLocation('Video call'),
    scheduleId: ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423'),
    bookingUrl: BookingUrl('https://scheduler.example.com/alice/30-minute-consultation'),
    meetingDescription: MeetingDescription('A short call to discuss your project.'),
  ),
  MeetingTypeEditedEvent(
    meetingTypeId: MeetingTypeId('e3b5aceb-a393-5517-acf5-fb11936414a5'),
    meetingTitle: MeetingTitle('30-minute consultation'),
    durationMinutes: DurationMinutes(30),
    meetingLocation: MeetingLocation('Video call'),
    scheduleId: ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423'),
  ),
  MeetingTypeDisabledEvent(meetingTypeId: MeetingTypeId('e3b5aceb-a393-5517-acf5-fb11936414a5')),
  MeetingTypeEnabledEvent(meetingTypeId: MeetingTypeId('e3b5aceb-a393-5517-acf5-fb11936414a5')),
  MeetingTypeDeletedEvent(meetingTypeId: MeetingTypeId('e3b5aceb-a393-5517-acf5-fb11936414a5')),
];
