board {
  workflows = [
    workflow.register_employee_on_first_sign_in,
    workflow.start_calendar_connection,
    workflow.record_calendar_connected,
    workflow.record_calendar_connection_failure,
    workflow.view_calendar_connection,
    workflow.record_host_busy_times,
    workflow.create_availability_schedule,
    workflow.set_weekly_hours,
    workflow.add_date_exception,
    workflow.change_date_exception,
    workflow.remove_date_exception,
    workflow.set_booking_limits,
    workflow.view_availability_schedules,
    workflow.create_meeting_type,
    workflow.view_my_meeting_types,
    workflow.edit_meeting_type,
    workflow.disable_meeting_type,
    workflow.enable_meeting_type,
    workflow.delete_meeting_type,
    workflow.view_available_slots,
    workflow.reserve_meeting_slot,
    workflow.request_booking_availability_check,
    workflow.verify_booked_slot,
    workflow.request_calendar_event,
    workflow.confirm_booked_meeting,
    workflow.fail_booking,
    workflow.view_booking_outcome,
    workflow.send_booking_confirmation,
    workflow.view_hosted_meetings,
    workflow.view_my_booked_meetings,
    workflow.view_meeting_details,
    workflow.request_meeting_reschedule,
    workflow.request_reschedule_availability_check,
    workflow.verify_rescheduled_slot,
    workflow.request_calendar_event_update,
    workflow.complete_meeting_reschedule,
    workflow.fail_meeting_reschedule,
    workflow.apply_direct_calendar_move,
    workflow.send_reschedule_notice,
    workflow.request_meeting_cancellation,
    workflow.request_calendar_event_deletion,
    workflow.complete_meeting_cancellation,
    workflow.fail_meeting_cancellation,
    workflow.apply_direct_calendar_deletion,
    workflow.send_cancellation_notice,
    workflow.complete_finished_meeting,
  ]
}

chapter "sign_in_and_connect_calendar" {
  title       = "Sign in and connect calendar"
  description = "An employee signs in with the corporate account and becomes known to the scheduler. A host connects the corporate calendar. Free/busy data then flows in, and connection failures stay visible and block unverified availability."
  workflows = [
    workflow.register_employee_on_first_sign_in,
    workflow.start_calendar_connection,
    workflow.record_calendar_connected,
    workflow.record_calendar_connection_failure,
    workflow.view_calendar_connection,
    workflow.record_host_busy_times,
  ]
}

chapter "configure_availability" {
  title       = "Configure availability"
  description = "A host creates availability schedules, with weekly hours, date exceptions, a booking window, minimum notice, and buffers. These rules bound every slot that colleagues can see. A host can change or remove a date exception later. Changes affect new bookings only."
  workflows = [
    workflow.create_availability_schedule,
    workflow.set_weekly_hours,
    workflow.add_date_exception,
    workflow.change_date_exception,
    workflow.remove_date_exception,
    workflow.set_booking_limits,
    workflow.view_availability_schedules,
  ]
}

chapter "publish_meeting_types" {
  title       = "Publish meeting types"
  description = "A host creates reusable meeting types. Each one has a stable booking link that the host copies and shares. Only active meeting types accept new bookings. Edits leave booked meetings as they are. A disabled or deleted meeting type stops new bookings, and its booked meetings remain."
  workflows = [
    workflow.create_meeting_type,
    workflow.view_my_meeting_types,
    workflow.edit_meeting_type,
    workflow.disable_meeting_type,
    workflow.enable_meeting_type,
    workflow.delete_meeting_type,
  ]
}

chapter "book_a_meeting" {
  title       = "Book a meeting"
  description = "A booker opens a link, sees only valid slots, and confirms one. The scheduler revalidates the slot and reserves it, then creates the calendar event. The meeting is confirmed only when the calendar accepts it. On failure the slot is released and the booker can choose another. The held slot is checked live against the host's calendar before the calendar event is created. Both participants are told by email."
  workflows = [
    workflow.view_available_slots,
    workflow.reserve_meeting_slot,
    workflow.request_booking_availability_check,
    workflow.verify_booked_slot,
    workflow.request_calendar_event,
    workflow.confirm_booked_meeting,
    workflow.fail_booking,
    workflow.view_booking_outcome,
    workflow.send_booking_confirmation,
  ]
}

chapter "view_scheduled_meetings" {
  title       = "View scheduled meetings"
  description = "Hosts and bookers see their meetings and open the details, from where they can reschedule or cancel. Active, canceled, and completed meetings are distinct."
  workflows = [
    workflow.view_hosted_meetings,
    workflow.view_my_booked_meetings,
    workflow.view_meeting_details,
  ]
}

chapter "reschedule_a_meeting" {
  title       = "Reschedule a meeting"
  description = "Either participant picks a different available slot. Both slots stay held until the calendar accepts the change. On success the original slot is released and both participants are told. On failure the new slot is released and the meeting keeps its original time. The new slot gets the same live check as a booking. A meeting moved directly in the calendar counts as rescheduled."
  workflows = [
    workflow.request_meeting_reschedule,
    workflow.request_reschedule_availability_check,
    workflow.verify_rescheduled_slot,
    workflow.request_calendar_event_update,
    workflow.complete_meeting_reschedule,
    workflow.fail_meeting_reschedule,
    workflow.apply_direct_calendar_move,
    workflow.send_reschedule_notice,
  ]
}

chapter "close_out_a_meeting" {
  title       = "Cancel or complete a meeting"
  description = "Either participant cancels a meeting. The slot is released once the calendar event is gone, and both participants are told. A meeting that runs to its end time becomes completed. A meeting deleted directly in the calendar counts as canceled."
  workflows = [
    workflow.request_meeting_cancellation,
    workflow.request_calendar_event_deletion,
    workflow.complete_meeting_cancellation,
    workflow.fail_meeting_cancellation,
    workflow.apply_direct_calendar_deletion,
    workflow.send_cancellation_notice,
    workflow.complete_finished_meeting,
  ]
}

actor "meeting_host" {
  description   = "An authenticated employee who connects a calendar, defines availability, and publishes meeting types so that others can book without coordination."
  auth_required = true
}

actor "meeting_booker" {
  description   = "An authenticated employee who opens a booking link and books a slot. Needs no calendar connection or other setup."
  auth_required = true
}

actor "meeting_participant" {
  description   = "The host or the booker of one specific meeting. Only participants can manage that meeting."
  auth_required = true
}

system "corporate_sso" {
  description = "The organization's single sign-on provider."
  external    = true
}

system "corporate_calendar" {
  description = "The company's existing calendar system. It exposes only free/busy data to the scheduler and holds the calendar events and invitations."
  external    = true
}

bounded_context "corporate_sso" {
  owner    = system.corporate_sso
  external = true

  event "corporate_sign_in_succeeded" {
    field "sso_subject" {
      type              = "String"
      correlation_key   = true
      deduplication_key = true
    }

    field "display_name" {
      type = "String"
      pii  = true
    }

    field "work_email" {
      type = "String"
      pii  = true
    }
  }
}

bounded_context "corporate_calendar" {
  owner    = system.corporate_calendar
  external = true

  field_type "scheduler_user_ref" {
    type = "String"
  }

  field_type "scheduler_meeting_ref" {
    type = "String"
  }

  field_type "failure_code" {
    type = "String"
  }

  field_type "free_busy_blocks" {
    cardinality = "List"
    type        = "Custom"

    subfield "busy_from" {
      type = "DateTime"
    }

    subfield "busy_until" {
      type = "DateTime"
    }
  }

  event "calendar_access_granted" {
    field "scheduler_user_ref" {
      type            = field_type.scheduler_user_ref
      correlation_key = true
    }

    field "calendar_account" {
      type = "String"
    }
  }

  event "calendar_access_failed" {
    fields = [field_type.failure_code]

    field "scheduler_user_ref" {
      type            = field_type.scheduler_user_ref
      correlation_key = true
    }
  }

  event "free_busy_reported" {
    fields = [field_type.free_busy_blocks]

    field "scheduler_user_ref" {
      type            = field_type.scheduler_user_ref
      correlation_key = true
    }
  }

  event "calendar_event_created" {
    field "scheduler_meeting_ref" {
      type            = field_type.scheduler_meeting_ref
      correlation_key = true
    }

    field "provider_event_ref" {
      type              = "String"
      deduplication_key = true
    }
  }

  event "calendar_event_creation_failed" {
    fields = [field_type.failure_code]

    field "scheduler_meeting_ref" {
      type            = field_type.scheduler_meeting_ref
      correlation_key = true
    }
  }

  event "calendar_event_updated" {
    field "scheduler_meeting_ref" {
      type            = field_type.scheduler_meeting_ref
      correlation_key = true
    }
  }

  event "calendar_event_update_failed" {
    fields = [field_type.failure_code]

    field "scheduler_meeting_ref" {
      type            = field_type.scheduler_meeting_ref
      correlation_key = true
    }
  }

  event "calendar_event_deleted" {
    field "scheduler_meeting_ref" {
      type            = field_type.scheduler_meeting_ref
      correlation_key = true
    }
  }

  event "calendar_event_deletion_failed" {
    fields = [field_type.failure_code]

    field "scheduler_meeting_ref" {
      type            = field_type.scheduler_meeting_ref
      correlation_key = true
    }
  }

  event "host_slot_found_free" {
    description = "The live free/busy answer: the host is free for the asked time. Holds no calendar content."

    field "scheduler_meeting_ref" {
      type            = field_type.scheduler_meeting_ref
      correlation_key = true
    }
  }

  event "host_slot_found_busy" {
    description = "The live free/busy answer: the host is busy for the asked time. Holds no calendar content."

    field "scheduler_meeting_ref" {
      type            = field_type.scheduler_meeting_ref
      correlation_key = true
    }
  }

  event "availability_check_failed" {
    description = "The calendar system could not answer the live free/busy question."
    fields      = [field_type.failure_code]

    field "scheduler_meeting_ref" {
      type            = field_type.scheduler_meeting_ref
      correlation_key = true
    }
  }

  event "calendar_event_moved_directly" {
    description = "Someone moved the meeting's event on the host's calendar, outside the scheduler. Holds the new times only."

    field "scheduler_meeting_ref" {
      type            = field_type.scheduler_meeting_ref
      correlation_key = true
    }

    field "moved_start" {
      type = "DateTime"
    }

    field "moved_end" {
      type = "DateTime"
    }
  }

  event "calendar_event_deleted_directly" {
    description = "Someone deleted the meeting's event from the host's calendar, outside the scheduler."

    field "scheduler_meeting_ref" {
      type            = field_type.scheduler_meeting_ref
      correlation_key = true
    }
  }
}

bounded_context "employee_directory" {
  description = "Employees known to the scheduler through corporate sign-in."

  field_type "employee_id" {
    type         = "UUID"
    id_attribute = true
  }

  field_type "employee_name" {
    type = "String"
  }

  field_type "employee_email" {
    type = "String"
  }

  aggregate "employee" {
    identity = field_type.employee_id
  }

  event "employee_registered" {
    aggregate = aggregate.employee
    fields    = [field_type.employee_id]

    field "employee_name" {
      type = field_type.employee_name
      pii  = true
    }

    field "employee_email" {
      type = field_type.employee_email
      pii  = true
    }
  }
}

bounded_context "host_setup" {
  description = "What a host configures: the calendar connection, availability rules, and meeting types."

  field_type "host_id" {
    type         = "UUID"
    id_attribute = true
    example      = "alice-employee-id"
  }

  field_type "calendar_account" {
    type = "String"
  }

  field_type "connection_failure" {
    type = "String"
  }

  field_type "busy_intervals" {
    cardinality = "List"
    type        = "Custom"

    subfield "busy_from" {
      type = "DateTime"
    }

    subfield "busy_until" {
      type = "DateTime"
    }
  }

  field_type "schedule_id" {
    type         = "UUID"
    id_attribute = true
  }

  field_type "schedule_name" {
    type    = "String"
    example = "Working hours"
  }

  field_type "time_zone" {
    type    = "String"
    example = "Europe/Berlin"
  }

  field_type "weekly_hours" {
    cardinality = "List"
    type        = "Custom"

    subfield "weekday" {
      type = "String"
    }

    subfield "start_time" {
      type = "String"
    }

    subfield "end_time" {
      type = "String"
    }
  }

  field_type "exception_date" {
    type = "Date"
  }

  field_type "exception_hours" {
    cardinality = "List"
    type        = "Custom"

    subfield "start_time" {
      type = "String"
    }

    subfield "end_time" {
      type = "String"
    }
  }

  field_type "date_exceptions" {
    cardinality = "List"
    type        = "Custom"

    subfield "exception_date" {
      type = "Date"
    }

    subfield "hours" {
      type = field_type.exception_hours
    }
  }

  field_type "accepting_bookings" {
    type = "Boolean"
  }

  field_type "booking_window_days" {
    type = "Int"
  }

  field_type "minimum_notice_minutes" {
    type = "Int"
  }

  field_type "buffer_before_minutes" {
    type = "Int"
  }

  field_type "buffer_after_minutes" {
    type = "Int"
  }

  field_type "meeting_type_id" {
    type         = "UUID"
    id_attribute = true
  }

  field_type "meeting_title" {
    type    = "String"
    example = "30-minute consultation"
  }

  field_type "meeting_description" {
    type = "String"
  }

  field_type "duration_minutes" {
    type    = "Int"
    example = 30
  }

  field_type "meeting_location" {
    type = "String"
  }

  field_type "booking_url" {
    type = "String"
  }

  aggregate "calendar_connection" {
    description = "The one calendar connection of a host."
    identity    = field_type.host_id
  }

  aggregate "availability_schedule" {
    identity = field_type.schedule_id
  }

  aggregate "meeting_type" {
    identity = field_type.meeting_type_id
  }

  event "calendar_connection_started" {
    aggregate = aggregate.calendar_connection
    fields    = [field_type.host_id]
  }

  event "calendar_connected" {
    aggregate = aggregate.calendar_connection
    fields    = [field_type.host_id, field_type.calendar_account]
  }

  event "calendar_connection_failed" {
    aggregate = aggregate.calendar_connection
    fields    = [field_type.host_id, field_type.connection_failure]
  }

  event "host_busy_times_recorded" {
    description = "Holds free/busy intervals only. Event titles, attendees, and contents never enter the scheduler."
    aggregate   = aggregate.calendar_connection
    fields      = [field_type.host_id, field_type.busy_intervals]
  }

  event "availability_schedule_created" {
    aggregate = aggregate.availability_schedule
    fields    = [field_type.schedule_id, field_type.host_id, field_type.schedule_name, field_type.time_zone]
  }

  event "weekly_hours_set" {
    aggregate = aggregate.availability_schedule
    fields    = [field_type.schedule_id, field_type.weekly_hours]
  }

  event "date_exception_added" {
    description = "Empty exception_hours mean that the whole date is unavailable."
    aggregate   = aggregate.availability_schedule
    fields      = [field_type.schedule_id, field_type.exception_date, field_type.exception_hours]
  }

  event "date_exception_changed" {
    description = "The date keeps an exception with different hours. Empty exception_hours mean that the whole date is unavailable."
    aggregate   = aggregate.availability_schedule
    fields      = [field_type.schedule_id, field_type.exception_date, field_type.exception_hours]
  }

  event "date_exception_removed" {
    description = "The date goes back to the schedule's weekly hours."
    aggregate   = aggregate.availability_schedule
    fields      = [field_type.schedule_id, field_type.exception_date]
  }

  event "booking_limits_set" {
    aggregate = aggregate.availability_schedule
    fields    = [field_type.schedule_id, field_type.booking_window_days, field_type.minimum_notice_minutes, field_type.buffer_before_minutes, field_type.buffer_after_minutes]
  }

  event "meeting_type_created" {
    aggregate = aggregate.meeting_type
    fields    = [field_type.meeting_type_id, field_type.host_id, field_type.meeting_title, field_type.duration_minutes, field_type.meeting_location, field_type.schedule_id, field_type.booking_url]

    field "meeting_description" {
      type     = field_type.meeting_description
      optional = true
    }
  }

  event "meeting_type_edited" {
    description = "Carries no booking_url, because the link stays stable across edits."
    aggregate   = aggregate.meeting_type
    fields      = [field_type.meeting_type_id, field_type.meeting_title, field_type.duration_minutes, field_type.meeting_location, field_type.schedule_id]

    field "meeting_description" {
      type     = field_type.meeting_description
      optional = true
    }
  }

  event "meeting_type_disabled" {
    aggregate = aggregate.meeting_type
    fields    = [field_type.meeting_type_id]
  }

  event "meeting_type_enabled" {
    aggregate = aggregate.meeting_type
    fields    = [field_type.meeting_type_id]
  }

  event "meeting_type_deleted" {
    aggregate = aggregate.meeting_type
    fields    = [field_type.meeting_type_id]
  }
}

bounded_context "meetings" {
  description = "Booked one-on-one meetings, from reservation to their end."

  field_type "meeting_id" {
    type         = "UUID"
    id_attribute = true
  }

  field_type "booker_id" {
    type         = "UUID"
    id_attribute = true
    example      = "bob-employee-id"
  }

  field_type "slot_start" {
    type = "DateTime"
  }

  field_type "slot_end" {
    type = "DateTime"
  }

  field_type "new_slot_start" {
    type = "DateTime"
  }

  field_type "new_slot_end" {
    type = "DateTime"
  }

  field_type "participants" {
    cardinality = "List"
    type        = "Custom"

    subfield "employee_id" {
      type = field_type.employee_directory.employee_id
    }

    subfield "name" {
      type = field_type.employee_directory.employee_name
      pii  = true
    }

    subfield "email" {
      type = field_type.employee_directory.employee_email
      pii  = true
    }

    subfield "role" {
      type = "String"
    }
  }

  field_type "requested_by" {
    type = "UUID"
  }

  field_type "calendar_event_id" {
    type = "String"
  }

  field_type "failure_reason" {
    type = "String"
  }

  field_type "meeting_status" {
    type = "String"
  }

  field_type "available_slots" {
    cardinality = "List"
    type        = "Custom"

    subfield "start_at" {
      type = "DateTime"
    }

    subfield "end_at" {
      type = "DateTime"
    }
  }

  aggregate "meeting" {
    description = "One booked meeting and its lifecycle. The no-overlap rule spans all active meetings of the host, see decision.no_overlap_spans_the_host."
    identity    = field_type.meeting_id
  }

  event "meeting_slot_reserved" {
    description = "The meeting record exists and its slot is held. The calendar event does not exist yet."
    aggregate   = aggregate.meeting
    fields = [
      field_type.meeting_id,
      field_type.host_setup.host_id,
      field_type.booker_id,
      field_type.host_setup.meeting_type_id,
      field_type.host_setup.meeting_title,
      field_type.host_setup.meeting_location,
      field_type.slot_start,
      field_type.slot_end,
      field_type.participants,
    ]
  }

  event "booking_availability_check_requested" {
    description = "The live free/busy question for the held slot. It asks for free/busy data only."
    aggregate   = aggregate.meeting
    fields      = [field_type.meeting_id, field_type.host_setup.host_id, field_type.slot_start, field_type.slot_end]
  }

  event "booking_slot_verified" {
    description = "The calendar system has confirmed that the host is free for the held slot."
    aggregate   = aggregate.meeting
    fields      = [field_type.meeting_id]
  }

  event "calendar_event_requested" {
    aggregate = aggregate.meeting
    fields    = [field_type.meeting_id]
  }

  event "meeting_confirmed" {
    aggregate = aggregate.meeting
    fields    = [field_type.meeting_id, field_type.calendar_event_id]
  }

  event "meeting_booking_failed" {
    description = "The held slot is released."
    aggregate   = aggregate.meeting
    fields      = [field_type.meeting_id, field_type.failure_reason]
  }

  event "booking_confirmation_sent" {
    aggregate = aggregate.meeting
    fields    = [field_type.meeting_id, field_type.participants]
  }

  event "meeting_reschedule_requested" {
    description = "The new slot is held as well. The original slot stays held until the calendar accepts the change."
    aggregate   = aggregate.meeting
    fields      = [field_type.meeting_id, field_type.host_setup.host_id, field_type.requested_by, field_type.new_slot_start, field_type.new_slot_end, field_type.calendar_event_id, field_type.participants]
  }

  event "reschedule_availability_check_requested" {
    description = "The live free/busy question for the new slot. It asks for free/busy data only."
    aggregate   = aggregate.meeting
    fields      = [field_type.meeting_id, field_type.host_setup.host_id, field_type.new_slot_start, field_type.new_slot_end]
  }

  event "new_slot_verified" {
    description = "The calendar system has confirmed that the host is free for the new slot."
    aggregate   = aggregate.meeting
    fields      = [field_type.meeting_id]
  }

  event "calendar_event_update_requested" {
    aggregate = aggregate.meeting
    fields    = [field_type.meeting_id, field_type.new_slot_start]
  }

  event "meeting_rescheduled" {
    description = "The new slot becomes the meeting time and the original slot is released."
    aggregate   = aggregate.meeting
    fields      = [field_type.meeting_id]
  }

  event "meeting_moved_in_calendar" {
    description = "The meeting's event was moved directly in the calendar, and the meeting takes that time. Any other slot that the meeting held is released."
    aggregate   = aggregate.meeting
    fields      = [field_type.meeting_id, field_type.new_slot_start, field_type.new_slot_end]
  }

  event "meeting_reschedule_failed" {
    description = "The new slot is released and the meeting keeps its original time."
    aggregate   = aggregate.meeting
    fields      = [field_type.meeting_id, field_type.failure_reason]
  }

  event "reschedule_notice_sent" {
    aggregate = aggregate.meeting
    fields    = [field_type.meeting_id, field_type.new_slot_start, field_type.participants]
  }

  event "meeting_cancellation_requested" {
    aggregate = aggregate.meeting
    fields    = [field_type.meeting_id, field_type.host_setup.host_id, field_type.requested_by, field_type.calendar_event_id, field_type.participants]
  }

  event "calendar_event_deletion_requested" {
    aggregate = aggregate.meeting
    fields    = [field_type.meeting_id]
  }

  event "meeting_canceled" {
    description = "Every slot that the meeting held is released. The cancellation came from the scheduler or from a direct deletion in the calendar."
    aggregate   = aggregate.meeting
    fields      = [field_type.meeting_id]
  }

  event "meeting_cancellation_failed" {
    description = "The meeting stays confirmed."
    aggregate   = aggregate.meeting
    fields      = [field_type.meeting_id, field_type.failure_reason]
  }

  event "cancellation_notice_sent" {
    aggregate = aggregate.meeting
    fields    = [field_type.meeting_id, field_type.participants]
  }

  event "meeting_completed" {
    aggregate = aggregate.meeting
    fields    = [field_type.meeting_id]
  }
}

lifecycle "employee" {
  aggregate = aggregate.employee_directory.employee

  state "registered" {
    path = "main"
  }

  transition "register" {
    command = command.register_employee_on_first_sign_in.register_employee
    events  = [event.employee_directory.employee_registered]
    before  = []
    after   = state.registered
  }
}

lifecycle "calendar_connection" {
  aggregate = aggregate.host_setup.calendar_connection

  state "connecting" {
    path = "main"
  }

  state "connected" {
    path = "main"
  }

  state "connection_failed" {
    path = "failure"
  }

  transition "start_first_connection" {
    command = command.start_calendar_connection.start_calendar_connection
    events  = [event.host_setup.calendar_connection_started]
    before  = []
    after   = state.connecting
  }

  transition "retry_failed_connection" {
    command = command.start_calendar_connection.start_calendar_connection
    events  = [event.host_setup.calendar_connection_started]
    before  = [state.connection_failed]
    after   = state.connecting
  }

  transition "access_granted" {
    command = command.record_calendar_connected.record_calendar_connected
    events  = [event.host_setup.calendar_connected]
    before  = [state.connecting]
    after   = state.connected
  }

  transition "access_failed" {
    command = command.record_calendar_connection_failure.record_connection_failure
    events  = [event.host_setup.calendar_connection_failed]
    before  = [state.connecting, state.connected]
    after   = state.connection_failed
  }

  transition "busy_times_refreshed" {
    command = command.record_host_busy_times.record_busy_times
    events  = [event.host_setup.host_busy_times_recorded]
    before  = [state.connected]
    after   = state.connected
  }

  invalid_transition "start_when_already_connected" {
    command = command.start_calendar_connection.start_calendar_connection
    reason  = "This calendar is already connected."
    before  = [state.connected]
  }
}

lifecycle "availability_schedule" {
  aggregate = aggregate.host_setup.availability_schedule

  state "defined" {
    path = "main"
  }

  transition "create" {
    command = command.create_availability_schedule.create_availability_schedule
    events  = [event.host_setup.availability_schedule_created]
    before  = []
    after   = state.defined
  }

  transition "set_weekly_hours" {
    command = command.set_weekly_hours.set_weekly_hours
    events  = [event.host_setup.weekly_hours_set]
    before  = [state.defined]
    after   = state.defined
  }

  transition "add_date_exception" {
    command = command.add_date_exception.add_date_exception
    events  = [event.host_setup.date_exception_added]
    before  = [state.defined]
    after   = state.defined
  }

  transition "change_date_exception" {
    command = command.change_date_exception.change_date_exception
    events  = [event.host_setup.date_exception_changed]
    before  = [state.defined]
    after   = state.defined
  }

  transition "remove_date_exception" {
    command = command.remove_date_exception.remove_date_exception
    events  = [event.host_setup.date_exception_removed]
    before  = [state.defined]
    after   = state.defined
  }

  transition "set_booking_limits" {
    command = command.set_booking_limits.set_booking_limits
    events  = [event.host_setup.booking_limits_set]
    before  = [state.defined]
    after   = state.defined
  }
}

lifecycle "meeting_type" {
  aggregate = aggregate.host_setup.meeting_type

  state "active" {
    path = "main"
  }

  state "disabled" {
    path = "main"
  }

  state "deleted" {
    end  = true
    path = "cancel"
  }

  transition "create" {
    command = command.create_meeting_type.create_meeting_type
    events  = [event.host_setup.meeting_type_created]
    before  = []
    after   = state.active
  }

  transition "edit_active" {
    command = command.edit_meeting_type.edit_meeting_type
    events  = [event.host_setup.meeting_type_edited]
    before  = [state.active]
    after   = state.active
  }

  transition "edit_disabled" {
    command = command.edit_meeting_type.edit_meeting_type
    events  = [event.host_setup.meeting_type_edited]
    before  = [state.disabled]
    after   = state.disabled
  }

  transition "disable" {
    command = command.disable_meeting_type.disable_meeting_type
    events  = [event.host_setup.meeting_type_disabled]
    before  = [state.active]
    after   = state.disabled
  }

  transition "enable" {
    command = command.enable_meeting_type.enable_meeting_type
    events  = [event.host_setup.meeting_type_enabled]
    before  = [state.disabled]
    after   = state.active
  }

  transition "delete" {
    command = command.delete_meeting_type.delete_meeting_type
    events  = [event.host_setup.meeting_type_deleted]
    before  = [state.active, state.disabled]
    after   = state.deleted
  }

  invalid_transition "edit_deleted" {
    command = command.edit_meeting_type.edit_meeting_type
    reason  = "A deleted meeting type cannot be edited."
    before  = [state.deleted]
  }

  invalid_transition "enable_deleted" {
    command = command.enable_meeting_type.enable_meeting_type
    reason  = "A deleted meeting type cannot be enabled."
    before  = [state.deleted]
  }
}

lifecycle "meeting" {
  aggregate = aggregate.meetings.meeting

  state "pending_calendar" {
    path = "main"
  }

  state "confirmed" {
    path = "main"
  }

  state "rescheduling" {
    path = "main"
  }

  state "canceling" {
    path = "cancel"
  }

  state "completed" {
    end  = true
    path = "main"
  }

  state "canceled" {
    end  = true
    path = "cancel"
  }

  state "booking_failed" {
    end  = true
    path = "failure"
  }

  transition "reserve" {
    command = command.reserve_meeting_slot.reserve_meeting_slot
    events  = [event.meetings.meeting_slot_reserved]
    before  = []
    after   = state.pending_calendar
  }

  transition "request_booking_check" {
    command = command.request_booking_availability_check.request_booking_availability_check
    events  = [event.meetings.booking_availability_check_requested]
    before  = [state.pending_calendar]
    after   = state.pending_calendar
  }

  transition "verify_booked_slot" {
    command = command.verify_booked_slot.record_booking_slot_verified
    events  = [event.meetings.booking_slot_verified]
    before  = [state.pending_calendar]
    after   = state.pending_calendar
  }

  transition "request_calendar_event" {
    command = command.request_calendar_event.request_calendar_event
    events  = [event.meetings.calendar_event_requested]
    before  = [state.pending_calendar]
    after   = state.pending_calendar
  }

  transition "confirm" {
    command = command.confirm_booked_meeting.confirm_meeting
    events  = [event.meetings.meeting_confirmed]
    before  = [state.pending_calendar]
    after   = state.confirmed
  }

  transition "fail_booking" {
    command = command.fail_booking.fail_booking
    events  = [event.meetings.meeting_booking_failed]
    before  = [state.pending_calendar]
    after   = state.booking_failed
  }

  transition "send_booking_confirmation" {
    command = command.send_booking_confirmation.send_booking_confirmation
    events  = [event.meetings.booking_confirmation_sent]
    before  = [state.confirmed]
    after   = state.confirmed
  }

  transition "request_reschedule" {
    command = command.request_meeting_reschedule.request_meeting_reschedule
    events  = [event.meetings.meeting_reschedule_requested]
    before  = [state.confirmed]
    after   = state.rescheduling
  }

  transition "request_reschedule_check" {
    command = command.request_reschedule_availability_check.request_reschedule_availability_check
    events  = [event.meetings.reschedule_availability_check_requested]
    before  = [state.rescheduling]
    after   = state.rescheduling
  }

  transition "verify_new_slot" {
    command = command.verify_rescheduled_slot.record_new_slot_verified
    events  = [event.meetings.new_slot_verified]
    before  = [state.rescheduling]
    after   = state.rescheduling
  }

  transition "request_calendar_update" {
    command = command.request_calendar_event_update.request_calendar_event_update
    events  = [event.meetings.calendar_event_update_requested]
    before  = [state.rescheduling]
    after   = state.rescheduling
  }

  transition "complete_reschedule" {
    command = command.complete_meeting_reschedule.complete_reschedule
    events  = [event.meetings.meeting_rescheduled]
    before  = [state.rescheduling]
    after   = state.confirmed
  }

  transition "fail_reschedule" {
    command = command.fail_meeting_reschedule.fail_reschedule
    events  = [event.meetings.meeting_reschedule_failed]
    before  = [state.rescheduling]
    after   = state.confirmed
  }

  transition "record_direct_move" {
    command = command.apply_direct_calendar_move.record_meeting_moved
    events  = [event.meetings.meeting_moved_in_calendar]
    before  = [state.confirmed, state.rescheduling]
    after   = state.confirmed
  }

  transition "send_reschedule_notice" {
    command = command.send_reschedule_notice.send_reschedule_notice
    events  = [event.meetings.reschedule_notice_sent]
    before  = [state.confirmed]
    after   = state.confirmed
  }

  transition "request_cancellation" {
    command = command.request_meeting_cancellation.request_meeting_cancellation
    events  = [event.meetings.meeting_cancellation_requested]
    before  = [state.confirmed]
    after   = state.canceling
  }

  transition "request_calendar_deletion" {
    command = command.request_calendar_event_deletion.request_calendar_event_deletion
    events  = [event.meetings.calendar_event_deletion_requested]
    before  = [state.canceling]
    after   = state.canceling
  }

  transition "complete_cancellation" {
    command = command.complete_meeting_cancellation.complete_cancellation
    events  = [event.meetings.meeting_canceled]
    before  = [state.canceling]
    after   = state.canceled
  }

  transition "fail_cancellation" {
    command = command.fail_meeting_cancellation.fail_cancellation
    events  = [event.meetings.meeting_cancellation_failed]
    before  = [state.canceling]
    after   = state.confirmed
  }

  transition "record_direct_deletion" {
    command = command.apply_direct_calendar_deletion.record_meeting_deleted
    events  = [event.meetings.meeting_canceled]
    before  = [state.confirmed, state.rescheduling, state.canceling]
    after   = state.canceled
  }

  transition "send_cancellation_notice" {
    command = command.send_cancellation_notice.send_cancellation_notice
    events  = [event.meetings.cancellation_notice_sent]
    before  = [state.canceled]
    after   = state.canceled
  }

  transition "complete" {
    command = command.complete_finished_meeting.complete_meeting
    events  = [event.meetings.meeting_completed]
    before  = [state.confirmed]
    after   = state.completed
  }

  invalid_transition "direct_move_during_cancellation" {
    command = command.apply_direct_calendar_move.record_meeting_moved
    reason  = "A meeting that is being canceled ignores a direct move."
    before  = [state.canceling]
  }

  invalid_transition "direct_move_after_the_end" {
    command = command.apply_direct_calendar_move.record_meeting_moved
    reason  = "A meeting that has ended or was canceled ignores a direct move."
    before  = [state.canceled, state.completed, state.booking_failed]
  }

  invalid_transition "direct_deletion_after_the_end" {
    command = command.apply_direct_calendar_deletion.record_meeting_deleted
    reason  = "A meeting that has ended or was canceled ignores a direct deletion."
    before  = [state.canceled, state.completed, state.booking_failed]
  }

  invalid_transition "reschedule_ended_meeting" {
    command = command.request_meeting_reschedule.request_meeting_reschedule
    reason  = "A meeting that has ended or was canceled cannot be rescheduled."
    before  = [state.canceled, state.completed, state.booking_failed]
  }

  invalid_transition "reschedule_during_another_change" {
    command = command.request_meeting_reschedule.request_meeting_reschedule
    reason  = "Another change to this meeting is still in progress."
    before  = [state.pending_calendar, state.rescheduling, state.canceling]
  }

  invalid_transition "cancel_ended_meeting" {
    command = command.request_meeting_cancellation.request_meeting_cancellation
    reason  = "A meeting that has ended or was canceled cannot be canceled."
    before  = [state.canceled, state.completed, state.booking_failed]
  }

  invalid_transition "cancel_during_another_change" {
    command = command.request_meeting_cancellation.request_meeting_cancellation
    reason  = "Another change to this meeting is still in progress."
    before  = [state.pending_calendar, state.rescheduling, state.canceling]
  }
}

automation "register_employee_on_first_sign_in" {
  description = "Translation. Trigger: the corporate SSO reports a successful sign-in."
  status      = "created"

  readmodel "sign_ins_to_register" {
    question = "Which corporate sign-ins have reported an employee to the scheduler?"
    fields   = [field_type.employee_directory.employee_id, field_type.employee_directory.employee_name, field_type.employee_directory.employee_email]
    from     = [event.corporate_sso.corporate_sign_in_succeeded]
    to       = [processor.employee_registrar]
  }

  processor "employee_registrar" {
    fields = [field_type.employee_directory.employee_id, field_type.employee_directory.employee_name, field_type.employee_directory.employee_email]
    to     = [command.register_employee]
  }

  command "register_employee" {
    aggregate         = aggregate.employee_directory.employee
    creates_aggregate = true
    fields            = [field_type.employee_directory.employee_id, field_type.employee_directory.employee_name, field_type.employee_directory.employee_email]
    to                = [event.employee_directory.employee_registered]
  }

  field_source {
    description = "The SSO subject identifies one employee."
    inputs      = [event.corporate_sso.corporate_sign_in_succeeded.field.sso_subject]
    target      = readmodel.sign_ins_to_register.field.employee_id
  }

  field_source {
    inputs = [event.corporate_sso.corporate_sign_in_succeeded.field.display_name]
    target = readmodel.sign_ins_to_register.field.employee_name
  }

  field_source {
    inputs = [event.corporate_sso.corporate_sign_in_succeeded.field.work_email]
    target = readmodel.sign_ins_to_register.field.employee_email
  }

  scenario "first_sign_in_registers_the_employee" {
    case = "happy_path"

    given {
      event = event.corporate_sso.corporate_sign_in_succeeded
    }

    when {
      processor = processor.employee_registrar
    }

    then {
      event = event.employee_directory.employee_registered
    }
  }

  scenario "repeat_sign_in_registers_nothing" {
    case = "business_duplicate"

    given {
      event = event.employee_directory.employee_registered
    }

    given {
      event = event.corporate_sso.corporate_sign_in_succeeded
    }

    when {
      processor = processor.employee_registrar
    }

    then {
      expect_no_dispatch = true
      command            = command.register_employee
    }
  }

  scenario "sign_in_is_listed_for_registration" {
    case = "appear"

    given {
      event = event.corporate_sso.corporate_sign_in_succeeded
    }

    then {
      readmodel = readmodel.sign_ins_to_register
    }
  }
}

state_change "start_calendar_connection" {
  description = "The host authorizes the scheduler with the organization's approved mechanism, with free/busy and event-write permissions only."
  status      = "created"

  screen "connect_calendar" {
    actor = actor.meeting_host
    to    = [command.start_calendar_connection]
  }

  command "start_calendar_connection" {
    aggregate         = aggregate.host_setup.calendar_connection
    creates_aggregate = true
    to                = [event.host_setup.calendar_connection_started]

    field "host_id" {
      type      = field_type.host_setup.host_id
      generated = true
    }
  }

  scenario "host_starts_connection" {
    case = "happy_path"

    when {
      command = command.start_calendar_connection
    }

    then {
      event = event.host_setup.calendar_connection_started
    }
  }

  scenario "host_retries_after_failure" {
    case = "alternative_path"

    given {
      event = event.host_setup.calendar_connection_failed
    }

    when {
      command = command.start_calendar_connection
    }

    then {
      event = event.host_setup.calendar_connection_started
    }
  }

  scenario "connected_calendar_is_not_connected_twice" {
    case = "state_violation"

    given {
      event = event.host_setup.calendar_connected
    }

    when {
      command = command.start_calendar_connection
    }

    then {
      error = "This calendar is already connected."
    }
  }
}

automation "record_calendar_connected" {
  description = "Translation of the calendar system's grant into the fact that the host's calendar is connected."
  status      = "created"

  readmodel "granted_calendar_access" {
    question = "Which hosts has the calendar system granted access for?"
    fields   = [field_type.host_setup.host_id, field_type.host_setup.calendar_account]
    from     = [event.corporate_calendar.calendar_access_granted]
    to       = [processor.connection_translator]
  }

  processor "connection_translator" {
    fields = [field_type.host_setup.host_id, field_type.host_setup.calendar_account]
    to     = [command.record_calendar_connected]
  }

  command "record_calendar_connected" {
    aggregate = aggregate.host_setup.calendar_connection
    fields    = [field_type.host_setup.host_id, field_type.host_setup.calendar_account]
    to        = [event.host_setup.calendar_connected]
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_access_granted.field.scheduler_user_ref]
    target = readmodel.granted_calendar_access.field.host_id
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_access_granted.field.calendar_account]
    target = readmodel.granted_calendar_access.field.calendar_account
  }

  scenario "grant_connects_the_calendar" {
    case = "happy_path"

    given {
      event = event.host_setup.calendar_connection_started
    }

    given {
      event = event.corporate_calendar.calendar_access_granted
    }

    when {
      processor = processor.connection_translator
    }

    then {
      event = event.host_setup.calendar_connected
    }
  }

  scenario "grant_is_listed" {
    case = "appear"

    given {
      event = event.corporate_calendar.calendar_access_granted
    }

    then {
      readmodel = readmodel.granted_calendar_access
    }
  }
}

automation "record_calendar_connection_failure" {
  description = "Translation of a failed authorization or a later loss of calendar access."
  status      = "created"

  readmodel "failed_calendar_access" {
    question = "Which hosts has the calendar system reported an access failure for?"
    fields   = [field_type.host_setup.host_id, field_type.host_setup.connection_failure]
    from     = [event.corporate_calendar.calendar_access_failed]
    to       = [processor.connection_failure_translator]
  }

  processor "connection_failure_translator" {
    fields = [field_type.host_setup.host_id, field_type.host_setup.connection_failure]
    to     = [command.record_connection_failure]
  }

  command "record_connection_failure" {
    aggregate = aggregate.host_setup.calendar_connection
    fields    = [field_type.host_setup.host_id, field_type.host_setup.connection_failure]
    to        = [event.host_setup.calendar_connection_failed]
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_access_failed.field.scheduler_user_ref]
    target = readmodel.failed_calendar_access.field.host_id
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_access_failed.field.failure_code]
    target = readmodel.failed_calendar_access.field.connection_failure
  }

  scenario "failure_during_connection_is_recorded" {
    case = "external_failure"

    given {
      event = event.host_setup.calendar_connection_started
    }

    given {
      event = event.corporate_calendar.calendar_access_failed
    }

    when {
      processor = processor.connection_failure_translator
    }

    then {
      event = event.host_setup.calendar_connection_failed
    }
  }

  scenario "lost_access_is_recorded" {
    case = "external_failure"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.corporate_calendar.calendar_access_failed
    }

    when {
      processor = processor.connection_failure_translator
    }

    then {
      event = event.host_setup.calendar_connection_failed
    }
  }

  scenario "failure_is_listed" {
    case = "appear"

    given {
      event = event.corporate_calendar.calendar_access_failed
    }

    then {
      readmodel = readmodel.failed_calendar_access
    }
  }
}

state_view "view_calendar_connection" {
  status = "created"

  readmodel "calendar_connection_status" {
    question = "Is my calendar connected, and if not, why not?"
    fields   = [field_type.host_setup.host_id, field_type.host_setup.calendar_account, field_type.host_setup.connection_failure]
    from = [
      event.host_setup.calendar_connection_started,
      event.host_setup.calendar_connected,
      event.host_setup.calendar_connection_failed,
    ]
    to = [screen.calendar_connection]

    field "connection_status" {
      type = "String"
    }
  }

  screen "calendar_connection" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.calendar_account, field_type.host_setup.connection_failure]

    field "connection_status" {
      type = "String"
    }
  }

  field_source {
    description = "The latest of the three events decides: connecting, connected, or failed."
    inputs      = [event.host_setup.calendar_connection_started.field.host_id, event.host_setup.calendar_connected.field.host_id, event.host_setup.calendar_connection_failed.field.host_id]
    target      = readmodel.calendar_connection_status.field.connection_status
  }

  scenario "no_connection_yet" {
    empty_history = true

    then {
      expect_empty_list = true
      readmodel         = readmodel.calendar_connection_status
    }
  }

  scenario "connected_calendar_is_shown" {
    case = "appear"

    given {
      event = event.host_setup.calendar_connection_started
    }

    given {
      event = event.host_setup.calendar_connected
    }

    then {
      examples  = [{ connection_status = "connected" }]
      readmodel = readmodel.calendar_connection_status
    }
  }

  scenario "connection_failure_is_visible" {
    case = "change"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.host_setup.calendar_connection_failed
    }

    then {
      examples  = [{ connection_status = "failed" }]
      readmodel = readmodel.calendar_connection_status
    }
  }
}

automation "record_host_busy_times" {
  description = "Translation of reported free/busy data. No other calendar content crosses this boundary."
  status      = "created"

  readmodel "reported_free_busy" {
    question = "What free/busy data has the calendar system reported for each host?"
    fields   = [field_type.host_setup.host_id, field_type.host_setup.busy_intervals]
    from     = [event.corporate_calendar.free_busy_reported]
    to       = [processor.free_busy_translator]
  }

  processor "free_busy_translator" {
    fields = [field_type.host_setup.host_id, field_type.host_setup.busy_intervals]
    to     = [command.record_busy_times]
  }

  command "record_busy_times" {
    aggregate = aggregate.host_setup.calendar_connection
    fields    = [field_type.host_setup.host_id, field_type.host_setup.busy_intervals]
    to        = [event.host_setup.host_busy_times_recorded]
  }

  field_source {
    inputs = [event.corporate_calendar.free_busy_reported.field.scheduler_user_ref]
    target = readmodel.reported_free_busy.field.host_id
  }

  field_source {
    inputs = [event.corporate_calendar.free_busy_reported.field.free_busy_blocks]
    target = readmodel.reported_free_busy.field.busy_intervals
  }

  scenario "reported_busy_times_are_recorded" {
    case = "happy_path"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.corporate_calendar.free_busy_reported
    }

    when {
      processor = processor.free_busy_translator
    }

    then {
      event = event.host_setup.host_busy_times_recorded
    }
  }

  scenario "report_is_listed" {
    case = "appear"

    given {
      event = event.corporate_calendar.free_busy_reported
    }

    then {
      readmodel = readmodel.reported_free_busy
    }
  }
}

state_change "create_availability_schedule" {
  status = "created"

  screen "new_availability_schedule" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.schedule_name, field_type.host_setup.time_zone]
    to     = [command.create_availability_schedule]
  }

  command "create_availability_schedule" {
    aggregate         = aggregate.host_setup.availability_schedule
    creates_aggregate = true
    fields            = [field_type.host_setup.schedule_name, field_type.host_setup.time_zone]
    to                = [event.host_setup.availability_schedule_created]

    field "schedule_id" {
      type      = field_type.host_setup.schedule_id
      generated = true
    }

    field "host_id" {
      type      = field_type.host_setup.host_id
      generated = true
    }
  }

  scenario "host_creates_a_schedule" {
    case = "happy_path"

    when {
      command = command.create_availability_schedule
    }

    then {
      examples = [{ schedule_name = "Working hours", time_zone = "Europe/Berlin" }]
      event    = event.host_setup.availability_schedule_created
    }
  }
}

state_change "set_weekly_hours" {
  description = "Recurring availability by weekday and time range, in the schedule's time zone."
  status      = "created"

  screen "edit_weekly_hours" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.schedule_id, field_type.host_setup.weekly_hours]
    to     = [command.set_weekly_hours]
  }

  command "set_weekly_hours" {
    aggregate = aggregate.host_setup.availability_schedule
    fields    = [field_type.host_setup.schedule_id, field_type.host_setup.weekly_hours]
    to        = [event.host_setup.weekly_hours_set]
  }

  scenario "host_sets_weekly_hours" {
    case = "happy_path"

    given {
      event = event.host_setup.availability_schedule_created
    }

    when {
      command = command.set_weekly_hours
    }

    then {
      event = event.host_setup.weekly_hours_set
    }
  }

  scenario "range_must_end_after_it_starts" {
    case = "refused_input"

    given {
      event = event.host_setup.availability_schedule_created
    }

    when {
      command = command.set_weekly_hours
    }

    then {
      error = "A time range must end after it starts."
    }
  }

  scenario "new_hours_leave_booked_meetings_alone" {
    description = "A meeting already booked outside the new hours stays as booked."
    case        = "variant"

    given {
      event = event.host_setup.availability_schedule_created
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    when {
      command = command.set_weekly_hours
    }

    then {
      event = event.host_setup.weekly_hours_set
    }
  }
}

state_change "add_date_exception" {
  status = "created"

  screen "add_exception" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.schedule_id, field_type.host_setup.exception_date, field_type.host_setup.exception_hours]
    to     = [command.add_date_exception]
  }

  command "add_date_exception" {
    aggregate = aggregate.host_setup.availability_schedule
    fields    = [field_type.host_setup.schedule_id, field_type.host_setup.exception_date, field_type.host_setup.exception_hours]
    to        = [event.host_setup.date_exception_added]
  }

  scenario "host_marks_a_day_unavailable" {
    case = "happy_path"

    given {
      event = event.host_setup.availability_schedule_created
    }

    when {
      command = command.add_date_exception
    }

    then {
      examples = [{ exception_date = "2027-03-24", exception_hours = [] }]
      event    = event.host_setup.date_exception_added
    }
  }

  scenario "host_sets_different_hours_for_a_day" {
    case = "variant"

    given {
      event = event.host_setup.availability_schedule_created
    }

    when {
      command = command.add_date_exception
    }

    then {
      event = event.host_setup.date_exception_added
    }
  }
}

state_change "change_date_exception" {
  status = "created"

  screen "change_exception" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.schedule_id, field_type.host_setup.exception_date, field_type.host_setup.exception_hours]
    to     = [command.change_date_exception]
  }

  command "change_date_exception" {
    aggregate = aggregate.host_setup.availability_schedule
    fields    = [field_type.host_setup.schedule_id, field_type.host_setup.exception_date, field_type.host_setup.exception_hours]
    to        = [event.host_setup.date_exception_changed]
  }

  scenario "host_changes_the_hours_of_an_exception" {
    case = "happy_path"

    given {
      event = event.host_setup.date_exception_added
    }

    when {
      command = command.change_date_exception
    }

    then {
      event = event.host_setup.date_exception_changed
    }
  }
}

state_change "remove_date_exception" {
  status = "created"

  screen "remove_exception" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.schedule_id, field_type.host_setup.exception_date]
    to     = [command.remove_date_exception]
  }

  command "remove_date_exception" {
    aggregate = aggregate.host_setup.availability_schedule
    fields    = [field_type.host_setup.schedule_id, field_type.host_setup.exception_date]
    to        = [event.host_setup.date_exception_removed]
  }

  scenario "host_removes_an_exception" {
    case = "happy_path"

    given {
      event = event.host_setup.date_exception_added
    }

    when {
      command = command.remove_date_exception
    }

    then {
      event = event.host_setup.date_exception_removed
    }
  }
}

state_change "set_booking_limits" {
  description = "The booking window, minimum advance notice, and buffers between meetings."
  status      = "created"

  screen "edit_booking_limits" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.schedule_id, field_type.host_setup.booking_window_days, field_type.host_setup.minimum_notice_minutes, field_type.host_setup.buffer_before_minutes, field_type.host_setup.buffer_after_minutes]
    to     = [command.set_booking_limits]
  }

  command "set_booking_limits" {
    aggregate = aggregate.host_setup.availability_schedule
    fields    = [field_type.host_setup.schedule_id, field_type.host_setup.booking_window_days, field_type.host_setup.minimum_notice_minutes, field_type.host_setup.buffer_before_minutes, field_type.host_setup.buffer_after_minutes]
    to        = [event.host_setup.booking_limits_set]
  }

  scenario "host_sets_booking_limits" {
    case = "happy_path"

    given {
      event = event.host_setup.availability_schedule_created
    }

    when {
      command = command.set_booking_limits
    }

    then {
      event = event.host_setup.booking_limits_set
    }
  }
}

state_view "view_availability_schedules" {
  status = "created"

  readmodel "my_availability_schedules" {
    question = "Which availability schedules have I defined, and what are their rules?"
    fields   = [field_type.host_setup.schedule_id, field_type.host_setup.host_id, field_type.host_setup.schedule_name, field_type.host_setup.time_zone, field_type.host_setup.weekly_hours, field_type.host_setup.date_exceptions, field_type.host_setup.booking_window_days, field_type.host_setup.minimum_notice_minutes, field_type.host_setup.buffer_before_minutes, field_type.host_setup.buffer_after_minutes]
    from = [
      event.host_setup.availability_schedule_created,
      event.host_setup.weekly_hours_set,
      event.host_setup.date_exception_added,
      event.host_setup.date_exception_changed,
      event.host_setup.date_exception_removed,
      event.host_setup.booking_limits_set,
    ]
    to = [screen.availability_schedules]
  }

  screen "availability_schedules" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.schedule_id, field_type.host_setup.schedule_name, field_type.host_setup.time_zone, field_type.host_setup.weekly_hours, field_type.host_setup.date_exceptions, field_type.host_setup.booking_window_days, field_type.host_setup.minimum_notice_minutes, field_type.host_setup.buffer_before_minutes, field_type.host_setup.buffer_after_minutes]
  }

  field_source {
    description = "The current exception of each date. A changed exception replaces its hours, and a removed exception leaves the list."
    inputs = [
      event.host_setup.date_exception_added.field.exception_date,
      event.host_setup.date_exception_added.field.exception_hours,
      event.host_setup.date_exception_changed.field.exception_hours,
      event.host_setup.date_exception_removed.field.exception_date,
    ]
    target = readmodel.my_availability_schedules.field.date_exceptions
  }

  scenario "no_schedule_yet" {
    empty_history = true

    then {
      expect_empty_list = true
      readmodel         = readmodel.my_availability_schedules
    }
  }

  scenario "new_schedule_appears" {
    case = "appear"

    given {
      event = event.host_setup.availability_schedule_created
    }

    then {
      readmodel = readmodel.my_availability_schedules
    }
  }

  scenario "rules_update_the_schedule" {
    case = "change"

    given {
      event = event.host_setup.availability_schedule_created
    }

    given {
      event = event.host_setup.weekly_hours_set
    }

    given {
      event = event.host_setup.booking_limits_set
    }

    then {
      readmodel = readmodel.my_availability_schedules
    }
  }

  scenario "changed_exception_updates_the_schedule" {
    case = "change"

    given {
      event = event.host_setup.availability_schedule_created
    }

    given {
      event = event.host_setup.date_exception_added
    }

    given {
      event = event.host_setup.date_exception_changed
    }

    then {
      readmodel = readmodel.my_availability_schedules
    }
  }

  scenario "removed_exception_leaves_the_schedule" {
    case = "disappear"

    given {
      event = event.host_setup.availability_schedule_created
    }

    given {
      event = event.host_setup.date_exception_added
    }

    given {
      event = event.host_setup.date_exception_removed
    }

    then {
      readmodel = readmodel.my_availability_schedules
    }
  }
}

state_change "create_meeting_type" {
  status = "created"

  screen "new_meeting_type" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.meeting_title, field_type.host_setup.duration_minutes, field_type.host_setup.meeting_location, field_type.host_setup.schedule_id]
    to     = [command.create_meeting_type]

    field "meeting_description" {
      type     = field_type.host_setup.meeting_description
      optional = true
    }
  }

  command "create_meeting_type" {
    aggregate         = aggregate.host_setup.meeting_type
    creates_aggregate = true
    fields            = [field_type.host_setup.meeting_title, field_type.host_setup.duration_minutes, field_type.host_setup.meeting_location, field_type.host_setup.schedule_id]
    to                = [event.host_setup.meeting_type_created]

    field "meeting_type_id" {
      type      = field_type.host_setup.meeting_type_id
      generated = true
    }

    field "host_id" {
      type      = field_type.host_setup.host_id
      generated = true
    }

    field "booking_url" {
      type      = field_type.host_setup.booking_url
      generated = true
    }

    field "meeting_description" {
      type     = field_type.host_setup.meeting_description
      optional = true
    }
  }

  scenario "host_creates_a_meeting_type" {
    case = "happy_path"

    given {
      event = event.host_setup.availability_schedule_created
    }

    when {
      command = command.create_meeting_type
    }

    then {
      examples = [{ meeting_title = "30-minute consultation", duration_minutes = 30 }]
      event    = event.host_setup.meeting_type_created
    }
  }

  scenario "schedule_must_exist" {
    case = "refused_input"

    when {
      command = command.create_meeting_type
    }

    then {
      error = "Choose an availability schedule for this meeting type."
    }
  }
}

state_view "view_my_meeting_types" {
  description = "The host copies a booking link from this list and shares it through corporate communication tools."
  status      = "created"

  readmodel "my_meeting_types" {
    question = "Which meeting types have I created, are they active, and what are their booking links?"
    fields   = [field_type.host_setup.meeting_type_id, field_type.host_setup.host_id, field_type.host_setup.meeting_title, field_type.host_setup.duration_minutes, field_type.host_setup.booking_url]
    from = [
      event.host_setup.meeting_type_created,
      event.host_setup.meeting_type_edited,
      event.host_setup.meeting_type_disabled,
      event.host_setup.meeting_type_enabled,
      event.host_setup.meeting_type_deleted,
    ]
    to = [screen.meeting_types]

    field "active" {
      type = "Boolean"
    }
  }

  screen "meeting_types" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.meeting_type_id, field_type.host_setup.meeting_title, field_type.host_setup.duration_minutes, field_type.host_setup.booking_url]

    field "active" {
      type = "Boolean"
    }
  }

  field_source {
    description = "Active when created or enabled, inactive when disabled."
    inputs      = [event.host_setup.meeting_type_created.field.meeting_type_id, event.host_setup.meeting_type_disabled.field.meeting_type_id, event.host_setup.meeting_type_enabled.field.meeting_type_id]
    target      = readmodel.my_meeting_types.field.active
  }

  scenario "no_meeting_type_yet" {
    empty_history = true

    then {
      expect_empty_list = true
      readmodel         = readmodel.my_meeting_types
    }
  }

  scenario "new_meeting_type_has_a_link" {
    case = "appear"

    given {
      event = event.host_setup.meeting_type_created
    }

    then {
      readmodel = readmodel.my_meeting_types
    }
  }

  scenario "edit_keeps_the_booking_link" {
    case = "change"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.meeting_type_edited
    }

    then {
      readmodel = readmodel.my_meeting_types
    }
  }

  scenario "disabled_meeting_type_is_marked_inactive" {
    case = "change"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.meeting_type_disabled
    }

    then {
      examples  = [{ active = false }]
      readmodel = readmodel.my_meeting_types
    }
  }

  scenario "deleted_meeting_type_disappears" {
    case = "disappear"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.meeting_type_deleted
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.my_meeting_types
    }
  }
}

state_change "edit_meeting_type" {
  status = "created"

  screen "edit_meeting_type_form" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.meeting_type_id, field_type.host_setup.meeting_title, field_type.host_setup.duration_minutes, field_type.host_setup.meeting_location, field_type.host_setup.schedule_id]
    to     = [command.edit_meeting_type]

    field "meeting_description" {
      type     = field_type.host_setup.meeting_description
      optional = true
    }
  }

  command "edit_meeting_type" {
    aggregate = aggregate.host_setup.meeting_type
    fields    = [field_type.host_setup.meeting_type_id, field_type.host_setup.meeting_title, field_type.host_setup.duration_minutes, field_type.host_setup.meeting_location, field_type.host_setup.schedule_id]
    to        = [event.host_setup.meeting_type_edited]

    field "meeting_description" {
      type     = field_type.host_setup.meeting_description
      optional = true
    }
  }

  scenario "host_edits_a_meeting_type" {
    case = "happy_path"

    given {
      event = event.host_setup.meeting_type_created
    }

    when {
      command = command.edit_meeting_type
    }

    then {
      event = event.host_setup.meeting_type_edited
    }
  }

  scenario "deleted_meeting_type_cannot_be_edited" {
    case = "state_violation"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.meeting_type_deleted
    }

    when {
      command = command.edit_meeting_type
    }

    then {
      error = "A deleted meeting type cannot be edited."
    }
  }

  scenario "edit_leaves_booked_meetings_alone" {
    description = "A booked meeting keeps the title, duration, and location captured at booking."
    case        = "variant"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    when {
      command = command.edit_meeting_type
    }

    then {
      event = event.host_setup.meeting_type_edited
    }
  }
}

state_change "disable_meeting_type" {
  status = "created"

  screen "disable_meeting_type_action" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.meeting_type_id]
    to     = [command.disable_meeting_type]
  }

  command "disable_meeting_type" {
    aggregate = aggregate.host_setup.meeting_type
    fields    = [field_type.host_setup.meeting_type_id]
    to        = [event.host_setup.meeting_type_disabled]
  }

  scenario "host_disables_a_meeting_type" {
    case = "happy_path"

    given {
      event = event.host_setup.meeting_type_created
    }

    when {
      command = command.disable_meeting_type
    }

    then {
      event = event.host_setup.meeting_type_disabled
    }
  }
}

state_change "enable_meeting_type" {
  status = "created"

  screen "enable_meeting_type_action" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.meeting_type_id]
    to     = [command.enable_meeting_type]
  }

  command "enable_meeting_type" {
    aggregate = aggregate.host_setup.meeting_type
    fields    = [field_type.host_setup.meeting_type_id]
    to        = [event.host_setup.meeting_type_enabled]
  }

  scenario "host_enables_a_disabled_meeting_type" {
    case = "happy_path"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.meeting_type_disabled
    }

    when {
      command = command.enable_meeting_type
    }

    then {
      event = event.host_setup.meeting_type_enabled
    }
  }

  scenario "deleted_meeting_type_cannot_be_enabled" {
    case = "state_violation"

    given {
      event = event.host_setup.meeting_type_deleted
    }

    when {
      command = command.enable_meeting_type
    }

    then {
      error = "A deleted meeting type cannot be enabled."
    }
  }
}

state_change "delete_meeting_type" {
  status = "created"

  screen "delete_meeting_type_action" {
    actor  = actor.meeting_host
    fields = [field_type.host_setup.meeting_type_id]
    to     = [command.delete_meeting_type]
  }

  command "delete_meeting_type" {
    aggregate = aggregate.host_setup.meeting_type
    fields    = [field_type.host_setup.meeting_type_id]
    to        = [event.host_setup.meeting_type_deleted]
  }

  scenario "host_deletes_a_meeting_type" {
    case = "happy_path"

    given {
      event = event.host_setup.meeting_type_created
    }

    when {
      command = command.delete_meeting_type
    }

    then {
      event = event.host_setup.meeting_type_deleted
    }
  }

  scenario "delete_leaves_upcoming_meetings_in_place" {
    description = "Upcoming meetings of the deleted type remain. They can still be rescheduled or canceled, and only new bookings stop."
    case        = "variant"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    when {
      command = command.delete_meeting_type
    }

    then {
      event = event.host_setup.meeting_type_deleted
    }
  }
}

state_view "view_available_slots" {
  description = "The slot calculation. A booker sees it on the booking page, and a participant sees it when picking a new time. Slots are absolute instants, and the screen shows them in the viewer's local time zone."
  status      = "created"

  readmodel "available_slots" {
    question = "Which times can be booked for this meeting type, and what are its details?"
    fields   = [field_type.host_setup.meeting_type_id, field_type.host_setup.host_id, field_type.host_setup.meeting_title, field_type.host_setup.duration_minutes, field_type.host_setup.meeting_location, field_type.meetings.available_slots, field_type.host_setup.accepting_bookings]
    from = [
      event.employee_directory.employee_registered,
      event.host_setup.meeting_type_created,
      event.host_setup.meeting_type_edited,
      event.host_setup.meeting_type_disabled,
      event.host_setup.meeting_type_enabled,
      event.host_setup.meeting_type_deleted,
      event.host_setup.availability_schedule_created,
      event.host_setup.weekly_hours_set,
      event.host_setup.date_exception_added,
      event.host_setup.date_exception_changed,
      event.host_setup.date_exception_removed,
      event.host_setup.booking_limits_set,
      event.host_setup.calendar_connected,
      event.host_setup.calendar_connection_failed,
      event.host_setup.host_busy_times_recorded,
      event.meetings.meeting_slot_reserved,
      event.meetings.meeting_booking_failed,
      event.meetings.meeting_reschedule_requested,
      event.meetings.meeting_rescheduled,
      event.meetings.meeting_moved_in_calendar,
      event.meetings.meeting_reschedule_failed,
      event.meetings.meeting_canceled,
    ]
    to = [screen.booking_page, screen.reschedule_slot_picker]

    field "host_name" {
      type = field_type.employee_directory.employee_name
      pii  = true
    }

    field "meeting_description" {
      type     = field_type.host_setup.meeting_description
      optional = true
    }
  }

  screen "booking_page" {
    actor  = actor.meeting_booker
    fields = [field_type.host_setup.meeting_type_id, field_type.host_setup.meeting_title, field_type.host_setup.duration_minutes, field_type.host_setup.meeting_location, field_type.meetings.available_slots, field_type.host_setup.accepting_bookings]

    field "host_name" {
      type = field_type.employee_directory.employee_name
      pii  = true
    }

    field "meeting_description" {
      type     = field_type.host_setup.meeting_description
      optional = true
    }
  }

  screen "reschedule_slot_picker" {
    actor  = actor.meeting_participant
    fields = [field_type.host_setup.meeting_title, field_type.meetings.available_slots]
  }

  field_source {
    description = "Start from the weekly hours in the schedule's time zone, so that local hours hold across daylight-saving changes. Apply date exceptions, the booking window, and minimum notice. Remove busy intervals and held slots with their buffers. Cut what remains to the meeting duration. Offer nothing when the calendar connection has failed. The state of the meeting type does not change this calculation, so a meeting of a disabled or deleted type can still get a new time."
    inputs = [
      event.host_setup.weekly_hours_set.field.weekly_hours,
      event.host_setup.date_exception_added.field.exception_date,
      event.host_setup.date_exception_changed.field.exception_hours,
      event.host_setup.date_exception_removed.field.exception_date,
      event.host_setup.booking_limits_set.field.minimum_notice_minutes,
      event.host_setup.booking_limits_set.field.booking_window_days,
      event.host_setup.booking_limits_set.field.buffer_before_minutes,
      event.host_setup.booking_limits_set.field.buffer_after_minutes,
      event.host_setup.host_busy_times_recorded.field.busy_intervals,
      event.host_setup.meeting_type_created.field.duration_minutes,
      event.meetings.meeting_slot_reserved.field.slot_start,
      event.meetings.meeting_reschedule_requested.field.new_slot_start,
      event.meetings.meeting_moved_in_calendar.field.new_slot_start,
    ]
    target = readmodel.available_slots.field.available_slots
  }

  field_source {
    description = "True only while the meeting type is enabled. When false, the booking page offers no slots. The reschedule picker ignores this value."
    inputs      = [event.host_setup.meeting_type_created.field.meeting_type_id, event.host_setup.meeting_type_disabled.field.meeting_type_id, event.host_setup.meeting_type_enabled.field.meeting_type_id, event.host_setup.meeting_type_deleted.field.meeting_type_id]
    target      = readmodel.available_slots.field.accepting_bookings
  }

  field_source {
    description = "The name of the employee who is the host of the meeting type."
    inputs      = [event.employee_directory.employee_registered.field.employee_name]
    target      = readmodel.available_slots.field.host_name
  }

  scenario "before_any_setup_nothing_is_bookable" {
    empty_history = true

    then {
      expect_empty_list = true
      readmodel         = readmodel.available_slots
    }
  }

  scenario "only_slots_that_satisfy_the_rules_appear" {
    description = "Alice has a 30-minute meeting type, working hours, and an existing meeting. Bob opens her link."
    case        = "appear"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.host_setup.availability_schedule_created
    }

    given {
      examples = [{ weekday = "Monday", start_time = "09:00", end_time = "10:30" }]
      event    = event.host_setup.weekly_hours_set
    }

    given {
      examples = [{ meeting_title = "30-minute consultation", duration_minutes = 30 }]
      event    = event.host_setup.meeting_type_created
    }

    given {
      examples = [{ busy_from = "2027-03-22T08:30:00Z", busy_until = "2027-03-22T09:00:00Z" }]
      event    = event.host_setup.host_busy_times_recorded
    }

    then {
      examples = [
        { start_at = "2027-03-22T08:00:00Z", end_at = "2027-03-22T08:30:00Z" },
        { start_at = "2027-03-22T09:00:00Z", end_at = "2027-03-22T09:30:00Z" },
      ]
      readmodel = readmodel.available_slots
    }
  }

  scenario "local_hours_hold_across_daylight_saving" {
    description = "Weekly hours start at 09:00 Europe/Berlin. Clocks change on 2027-03-28, so the same local time is a different instant on each side."
    case        = "appear"

    given {
      examples = [{ time_zone = "Europe/Berlin" }]
      event    = event.host_setup.availability_schedule_created
    }

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      examples = [{ weekday = "Monday", start_time = "09:00", end_time = "09:30" }]
      event    = event.host_setup.weekly_hours_set
    }

    given {
      event = event.host_setup.meeting_type_created
    }

    then {
      examples = [
        { start_at = "2027-03-22T08:00:00Z", end_at = "2027-03-22T08:30:00Z" },
        { start_at = "2027-03-29T07:00:00Z", end_at = "2027-03-29T07:30:00Z" },
      ]
      readmodel = readmodel.available_slots
    }
  }

  scenario "unavailable_day_offers_no_slots" {
    case = "disappear"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.host_setup.weekly_hours_set
    }

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.date_exception_added
    }

    then {
      readmodel = readmodel.available_slots
    }
  }

  scenario "failed_connection_offers_no_unverified_slots" {
    case = "disappear"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.host_setup.weekly_hours_set
    }

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.calendar_connection_failed
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.available_slots
    }
  }

  scenario "disabled_meeting_type_stops_new_bookings" {
    description = "The booking page offers no slots. A booked meeting of this type can still get a new time."
    case        = "change"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.host_setup.weekly_hours_set
    }

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.meeting_type_disabled
    }

    then {
      examples  = [{ accepting_bookings = false }]
      readmodel = readmodel.available_slots
    }
  }

  scenario "reserved_slot_is_removed" {
    case = "disappear"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.host_setup.weekly_hours_set
    }

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.meetings.meeting_slot_reserved
    }

    then {
      readmodel = readmodel.available_slots
    }
  }

  scenario "failed_booking_returns_the_slot" {
    case = "appear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_booking_failed
    }

    then {
      readmodel = readmodel.available_slots
    }
  }

  scenario "both_slots_are_held_during_a_reschedule" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    then {
      readmodel = readmodel.available_slots
    }
  }

  scenario "reschedule_returns_the_original_slot" {
    description = "Bob moves the meeting with Alice. The original time can be booked again."
    case        = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.meeting_rescheduled
    }

    then {
      readmodel = readmodel.available_slots
    }
  }

  scenario "failed_reschedule_returns_the_new_slot" {
    case = "change"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.meeting_reschedule_failed
    }

    then {
      readmodel = readmodel.available_slots
    }
  }

  scenario "canceled_meeting_returns_its_slot" {
    case = "appear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_canceled
    }

    then {
      readmodel = readmodel.available_slots
    }
  }

  scenario "deleted_meeting_type_stops_new_bookings" {
    description = "The booking page offers no slots. A booked meeting of this type can still get a new time."
    case        = "change"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.host_setup.weekly_hours_set
    }

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.meeting_type_deleted
    }

    then {
      examples  = [{ accepting_bookings = false }]
      readmodel = readmodel.available_slots
    }
  }

  scenario "removed_exception_reopens_the_day" {
    case = "appear"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.host_setup.weekly_hours_set
    }

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.date_exception_added
    }

    given {
      event = event.host_setup.date_exception_removed
    }

    then {
      readmodel = readmodel.available_slots
    }
  }

  scenario "changed_exception_changes_the_day" {
    case = "change"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.host_setup.weekly_hours_set
    }

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.date_exception_added
    }

    given {
      event = event.host_setup.date_exception_changed
    }

    then {
      readmodel = readmodel.available_slots
    }
  }

  scenario "direct_move_swaps_the_held_slot" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_moved_in_calendar
    }

    then {
      readmodel = readmodel.available_slots
    }
  }
}

state_change "reserve_meeting_slot" {
  description = "The booker reviews the details and confirms. This step checks the last known data and guards against double booking. The held slot then gets a live check against the host's calendar before the meeting is confirmed."
  status      = "created"

  screen "review_booking" {
    actor  = actor.meeting_booker
    fields = [field_type.host_setup.meeting_type_id, field_type.meetings.slot_start, field_type.meetings.slot_end]
    to     = [command.reserve_meeting_slot]
  }

  command "reserve_meeting_slot" {
    aggregate              = aggregate.meetings.meeting
    aggregate_dependencies = [aggregate.host_setup.meeting_type, aggregate.host_setup.availability_schedule, aggregate.host_setup.calendar_connection]
    creates_aggregate      = true
    fields                 = [field_type.host_setup.meeting_type_id, field_type.meetings.slot_start, field_type.meetings.slot_end]
    to                     = [event.meetings.meeting_slot_reserved]

    field "meeting_id" {
      type      = field_type.meetings.meeting_id
      generated = true
    }

    field "host_id" {
      type      = field_type.host_setup.host_id
      generated = true
    }

    field "booker_id" {
      type      = field_type.meetings.booker_id
      generated = true
    }

    field "meeting_title" {
      type      = field_type.host_setup.meeting_title
      generated = true
    }

    field "meeting_location" {
      type      = field_type.host_setup.meeting_location
      generated = true
    }

    field "participants" {
      type      = field_type.meetings.participants
      generated = true
    }
  }

  scenario "booker_reserves_a_free_slot" {
    case = "happy_path"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.host_setup.weekly_hours_set
    }

    given {
      event = event.host_setup.meeting_type_created
    }

    when {
      examples = [{ slot_start = "2027-03-22T09:00:00Z", slot_end = "2027-03-22T09:30:00Z" }]
      command  = command.reserve_meeting_slot
    }

    then {
      event = event.meetings.meeting_slot_reserved
    }
  }

  scenario "concurrent_booking_loses" {
    description = "Two employees submit the same host time. The first reservation wins."
    case        = "state_violation"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.meetings.meeting_slot_reserved
    }

    when {
      command = command.reserve_meeting_slot
    }

    then {
      error = "This time was just booked. Please choose another slot."
    }
  }

  scenario "overlap_across_meeting_types_is_refused" {
    description = "A 60-minute booking overlaps a 15-minute booking of another meeting type of the same host."
    case        = "state_violation"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.meetings.meeting_slot_reserved
    }

    when {
      command = command.reserve_meeting_slot
    }

    then {
      error = "This time was just booked. Please choose another slot."
    }
  }

  scenario "slot_held_by_a_reschedule_is_refused" {
    case = "state_violation"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    when {
      command = command.reserve_meeting_slot
    }

    then {
      error = "This time was just booked. Please choose another slot."
    }
  }

  scenario "slot_that_became_busy_is_refused" {
    case = "state_violation"

    given {
      event = event.host_setup.calendar_connected
    }

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.host_busy_times_recorded
    }

    when {
      command = command.reserve_meeting_slot
    }

    then {
      error = "This time is no longer available. Please choose another slot."
    }
  }

  scenario "slot_outside_the_rules_is_refused" {
    case = "limit"

    given {
      event = event.host_setup.booking_limits_set
    }

    given {
      event = event.host_setup.meeting_type_created
    }

    when {
      command = command.reserve_meeting_slot
    }

    then {
      error = "This time is outside the host's booking rules. Please choose another slot."
    }
  }

  scenario "disabled_meeting_type_is_refused" {
    case = "state_violation"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.meeting_type_disabled
    }

    when {
      command = command.reserve_meeting_slot
    }

    then {
      error = "This meeting type is not accepting bookings."
    }
  }

  scenario "unverified_calendar_is_refused" {
    case = "external_failure"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.calendar_connection_failed
    }

    when {
      command = command.reserve_meeting_slot
    }

    then {
      error = "The host's availability cannot be verified right now. Please try again later."
    }
  }

  scenario "unauthenticated_booking_is_refused" {
    case = "authorization"

    given {
      event = event.host_setup.meeting_type_created
    }

    when {
      command = command.reserve_meeting_slot
    }

    then {
      error = "Sign in with your corporate account to book this meeting."
    }
  }

  scenario "deleted_meeting_type_is_refused" {
    case = "state_violation"

    given {
      event = event.host_setup.meeting_type_created
    }

    given {
      event = event.host_setup.meeting_type_deleted
    }

    when {
      command = command.reserve_meeting_slot
    }

    then {
      error = "This meeting type is not accepting bookings."
    }
  }

  scenario "host_cannot_book_their_own_link" {
    description = "The signed-in employee is the host of this meeting type."
    case        = "authorization"

    given {
      event = event.host_setup.meeting_type_created
    }

    when {
      command = command.reserve_meeting_slot
    }

    then {
      error = "You cannot book a meeting with yourself."
    }
  }
}

automation "request_booking_availability_check" {
  description = "Worker. Asks the calendar system whether the host is free for the held slot, right now. Only free/busy data is asked for."
  status      = "created"

  readmodel "reservations_awaiting_live_check" {
    question = "Which held slots still need a live check of the host's calendar?"
    fields   = [field_type.meetings.meeting_id, field_type.host_setup.host_id, field_type.meetings.slot_start, field_type.meetings.slot_end]
    from     = [event.meetings.meeting_slot_reserved, event.meetings.booking_availability_check_requested]
    to       = [processor.booking_check_requester]
  }

  processor "booking_check_requester" {
    fields = [field_type.meetings.meeting_id, field_type.host_setup.host_id, field_type.meetings.slot_start, field_type.meetings.slot_end]
    to     = [command.request_booking_availability_check]
  }

  command "request_booking_availability_check" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id, field_type.host_setup.host_id, field_type.meetings.slot_start, field_type.meetings.slot_end]
    to        = [event.meetings.booking_availability_check_requested]
  }

  scenario "check_is_requested" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      readmodel = readmodel.reservations_awaiting_live_check
    }

    when {
      processor = processor.booking_check_requester
    }

    then {
      event = event.meetings.booking_availability_check_requested
    }
  }

  scenario "held_slot_waits_for_its_check" {
    case = "appear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    then {
      readmodel = readmodel.reservations_awaiting_live_check
    }
  }

  scenario "requested_check_leaves_the_list" {
    case = "disappear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.booking_availability_check_requested
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.reservations_awaiting_live_check
    }
  }
}

automation "verify_booked_slot" {
  description = "Translation. The calendar system reports that the host is free for the held slot."
  status      = "created"

  readmodel "free_answers_for_bookings" {
    question = "For which held slots has the calendar system confirmed that the host is free?"
    fields   = [field_type.meetings.meeting_id]
    from     = [event.corporate_calendar.host_slot_found_free, event.meetings.booking_availability_check_requested]
    to       = [processor.booking_free_translator]
  }

  processor "booking_free_translator" {
    fields = [field_type.meetings.meeting_id]
    to     = [command.record_booking_slot_verified]
  }

  command "record_booking_slot_verified" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id]
    to        = [event.meetings.booking_slot_verified]
  }

  field_source {
    description = "The meeting named in the answer. The request lists only the answers that belong to this kind of check."
    inputs      = [event.corporate_calendar.host_slot_found_free.field.scheduler_meeting_ref, event.meetings.booking_availability_check_requested.field.meeting_id]
    target      = readmodel.free_answers_for_bookings.field.meeting_id
  }

  scenario "free_host_verifies_the_slot" {
    case = "happy_path"

    given {
      event = event.meetings.booking_availability_check_requested
    }

    given {
      event = event.corporate_calendar.host_slot_found_free
    }

    when {
      processor = processor.booking_free_translator
    }

    then {
      event = event.meetings.booking_slot_verified
    }
  }

  scenario "free_answer_is_listed" {
    case = "appear"

    given {
      event = event.meetings.booking_availability_check_requested
    }

    given {
      event = event.corporate_calendar.host_slot_found_free
    }

    then {
      readmodel = readmodel.free_answers_for_bookings
    }
  }
}

automation "request_calendar_event" {
  description = "Worker. Once the live check has passed, asks the calendar system to create the event with both participants, which also sends the invitation."
  status      = "created"

  readmodel "reservations_awaiting_calendar_event" {
    question = "Which verified reservations still need a calendar event?"
    fields   = [field_type.meetings.meeting_id, field_type.host_setup.meeting_title, field_type.host_setup.meeting_location, field_type.meetings.slot_start, field_type.meetings.slot_end, field_type.meetings.participants]
    from     = [event.meetings.meeting_slot_reserved, event.meetings.booking_slot_verified, event.meetings.calendar_event_requested]
    to       = [processor.calendar_event_requester]
  }

  processor "calendar_event_requester" {
    fields = [field_type.meetings.meeting_id, field_type.host_setup.meeting_title, field_type.host_setup.meeting_location, field_type.meetings.slot_start, field_type.meetings.slot_end, field_type.meetings.participants]
    to     = [command.request_calendar_event]
  }

  command "request_calendar_event" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id]
    to        = [event.meetings.calendar_event_requested]
  }

  scenario "reservation_requests_a_calendar_event" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.booking_slot_verified
    }

    given {
      readmodel = readmodel.reservations_awaiting_calendar_event
    }

    when {
      processor = processor.calendar_event_requester
    }

    then {
      event = event.meetings.calendar_event_requested
    }
  }

  scenario "reservation_waits_for_its_calendar_event" {
    case = "appear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.booking_slot_verified
    }

    then {
      readmodel = readmodel.reservations_awaiting_calendar_event
    }
  }

  scenario "requested_reservation_leaves_the_list" {
    case = "disappear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.booking_slot_verified
    }

    given {
      event = event.meetings.calendar_event_requested
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.reservations_awaiting_calendar_event
    }
  }

  scenario "unchecked_reservation_is_not_requested" {
    case = "disappear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.reservations_awaiting_calendar_event
    }
  }
}

automation "confirm_booked_meeting" {
  description = "Translation. The calendar system has created the event and sent the invitation."
  status      = "created"

  readmodel "created_calendar_events" {
    question = "Which meetings has the calendar system created an event for?"
    fields   = [field_type.meetings.meeting_id, field_type.meetings.calendar_event_id]
    from     = [event.corporate_calendar.calendar_event_created]
    to       = [processor.calendar_created_translator]
  }

  processor "calendar_created_translator" {
    fields = [field_type.meetings.meeting_id, field_type.meetings.calendar_event_id]
    to     = [command.confirm_meeting]
  }

  command "confirm_meeting" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id, field_type.meetings.calendar_event_id]
    to        = [event.meetings.meeting_confirmed]
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_event_created.field.scheduler_meeting_ref]
    target = readmodel.created_calendar_events.field.meeting_id
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_event_created.field.provider_event_ref]
    target = readmodel.created_calendar_events.field.calendar_event_id
  }

  scenario "created_event_confirms_the_meeting" {
    case = "happy_path"

    given {
      event = event.meetings.calendar_event_requested
    }

    given {
      event = event.corporate_calendar.calendar_event_created
    }

    when {
      processor = processor.calendar_created_translator
    }

    then {
      event = event.meetings.meeting_confirmed
    }
  }

  scenario "created_event_is_listed" {
    case = "appear"

    given {
      event = event.corporate_calendar.calendar_event_created
    }

    then {
      readmodel = readmodel.created_calendar_events
    }
  }
}

automation "fail_booking" {
  description = "Translation. The live check found the host busy or could not be answered, or the calendar system could not create the event. The reservation does not stand and the slot is released."
  status      = "created"

  readmodel "failed_calendar_events" {
    question = "Which bookings failed their live check, or could the calendar system not create an event for?"
    fields   = [field_type.meetings.meeting_id, field_type.meetings.failure_reason]
    from     = [event.corporate_calendar.calendar_event_creation_failed, event.corporate_calendar.host_slot_found_busy, event.corporate_calendar.availability_check_failed, event.meetings.booking_availability_check_requested]
    to       = [processor.calendar_failure_translator]
  }

  processor "calendar_failure_translator" {
    fields = [field_type.meetings.meeting_id, field_type.meetings.failure_reason]
    to     = [command.fail_booking]
  }

  command "fail_booking" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id, field_type.meetings.failure_reason]
    to        = [event.meetings.meeting_booking_failed]
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_event_creation_failed.field.scheduler_meeting_ref, event.corporate_calendar.host_slot_found_busy.field.scheduler_meeting_ref, event.corporate_calendar.availability_check_failed.field.scheduler_meeting_ref]
    target = readmodel.failed_calendar_events.field.meeting_id
  }

  field_source {
    description = "A busy answer gives 'This time is no longer available. Please choose another slot.' A failed check gives 'The host's availability cannot be verified right now. Please try again later.' A refused calendar change keeps its failure code."
    inputs      = [event.corporate_calendar.calendar_event_creation_failed.field.failure_code, event.corporate_calendar.host_slot_found_busy.field.scheduler_meeting_ref, event.corporate_calendar.availability_check_failed.field.failure_code]
    target      = readmodel.failed_calendar_events.field.failure_reason
  }

  scenario "calendar_failure_fails_the_booking" {
    case = "external_failure"

    given {
      event = event.meetings.calendar_event_requested
    }

    given {
      event = event.corporate_calendar.calendar_event_creation_failed
    }

    when {
      processor = processor.calendar_failure_translator
    }

    then {
      event = event.meetings.meeting_booking_failed
    }
  }

  scenario "calendar_failure_is_listed" {
    case = "appear"

    given {
      event = event.corporate_calendar.calendar_event_creation_failed
    }

    then {
      readmodel = readmodel.failed_calendar_events
    }
  }

  scenario "busy_host_fails_the_booking" {
    case = "external_failure"

    given {
      event = event.meetings.booking_availability_check_requested
    }

    given {
      event = event.corporate_calendar.host_slot_found_busy
    }

    when {
      processor = processor.calendar_failure_translator
    }

    then {
      event = event.meetings.meeting_booking_failed
    }
  }

  scenario "unanswered_check_fails_the_booking" {
    case = "external_failure"

    given {
      event = event.meetings.booking_availability_check_requested
    }

    given {
      event = event.corporate_calendar.availability_check_failed
    }

    when {
      processor = processor.calendar_failure_translator
    }

    then {
      event = event.meetings.meeting_booking_failed
    }
  }
}

state_view "view_booking_outcome" {
  description = "After confirming, the booker sees whether the booking succeeded. On failure the screen shows a clear error and leads back to the slots."
  status      = "created"

  readmodel "booking_outcome" {
    question = "Did my booking succeed, and if not, why not?"
    fields   = [field_type.meetings.meeting_id, field_type.host_setup.meeting_title, field_type.meetings.slot_start, field_type.meetings.slot_end, field_type.meetings.failure_reason, field_type.meetings.meeting_status]
    from     = [event.meetings.meeting_slot_reserved, event.meetings.meeting_confirmed, event.meetings.meeting_booking_failed]
    to       = [screen.booking_result]
  }

  screen "booking_result" {
    actor  = actor.meeting_booker
    fields = [field_type.host_setup.meeting_title, field_type.meetings.slot_start, field_type.meetings.slot_end, field_type.meetings.failure_reason, field_type.meetings.meeting_status]
  }

  field_source {
    description = "Pending after the reservation, then confirmed or failed."
    inputs      = [event.meetings.meeting_slot_reserved.field.meeting_id, event.meetings.meeting_confirmed.field.meeting_id, event.meetings.meeting_booking_failed.field.meeting_id]
    target      = readmodel.booking_outcome.field.meeting_status
  }

  scenario "reserved_booking_is_pending" {
    case = "appear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    then {
      examples  = [{ meeting_status = "pending" }]
      readmodel = readmodel.booking_outcome
    }
  }

  scenario "confirmed_booking_is_shown" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    then {
      examples  = [{ meeting_status = "confirmed" }]
      readmodel = readmodel.booking_outcome
    }
  }

  scenario "failed_booking_shows_why" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_booking_failed
    }

    then {
      examples  = [{ meeting_status = "failed" }]
      readmodel = readmodel.booking_outcome
    }
  }
}

automation "send_booking_confirmation" {
  description = "Worker. Both participants receive a confirmation email once the meeting is confirmed."
  status      = "created"

  readmodel "confirmations_to_send" {
    question = "Which confirmed meetings have not yet been announced to both participants?"
    fields   = [field_type.meetings.meeting_id, field_type.meetings.participants]
    from     = [event.meetings.meeting_slot_reserved, event.meetings.meeting_confirmed, event.meetings.booking_confirmation_sent]
    to       = [processor.confirmation_sender]
  }

  processor "confirmation_sender" {
    fields = [field_type.meetings.meeting_id, field_type.meetings.participants]
    to     = [command.send_booking_confirmation]
  }

  command "send_booking_confirmation" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id, field_type.meetings.participants]
    to        = [event.meetings.booking_confirmation_sent]
  }

  scenario "confirmed_meeting_is_announced" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      readmodel = readmodel.confirmations_to_send
    }

    when {
      processor = processor.confirmation_sender
    }

    then {
      event = event.meetings.booking_confirmation_sent
    }
  }

  scenario "confirmed_meeting_waits_for_announcement" {
    case = "appear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    then {
      readmodel = readmodel.confirmations_to_send
    }
  }

  scenario "reservation_alone_is_not_announced" {
    case = "disappear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.confirmations_to_send
    }
  }

  scenario "announced_meeting_leaves_the_list" {
    case = "disappear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.booking_confirmation_sent
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.confirmations_to_send
    }
  }
}

state_view "view_hosted_meetings" {
  description = "Meetings booked through the host's links. A row appears when the meeting is confirmed."
  status      = "created"

  readmodel "hosted_meetings" {
    question = "Which meetings were booked through my links, and what is their status?"
    fields   = [field_type.meetings.meeting_id, field_type.host_setup.host_id, field_type.host_setup.meeting_title, field_type.meetings.slot_start, field_type.meetings.slot_end, field_type.meetings.participants, field_type.meetings.meeting_status]
    from = [
      event.meetings.meeting_slot_reserved,
      event.meetings.meeting_confirmed,
      event.meetings.meeting_reschedule_requested,
      event.meetings.meeting_rescheduled,
      event.meetings.meeting_moved_in_calendar,
      event.meetings.meeting_canceled,
      event.meetings.meeting_completed,
    ]
    to = [screen.hosted_meetings]
  }

  screen "hosted_meetings" {
    actor  = actor.meeting_host
    fields = [field_type.meetings.meeting_id, field_type.host_setup.meeting_title, field_type.meetings.slot_start, field_type.meetings.slot_end, field_type.meetings.participants, field_type.meetings.meeting_status]
  }

  field_source {
    description = "The latest of the meeting's time facts decides: the reserved slot, then the slot of the latest completed reschedule or direct calendar move."
    inputs      = [event.meetings.meeting_slot_reserved.field.slot_start, event.meetings.meeting_reschedule_requested.field.new_slot_start, event.meetings.meeting_moved_in_calendar.field.new_slot_start]
    target      = readmodel.hosted_meetings.field.slot_start
  }

  field_source {
    description = "The latest of the meeting's time facts decides: the reserved slot, then the slot of the latest completed reschedule or direct calendar move."
    inputs      = [event.meetings.meeting_slot_reserved.field.slot_end, event.meetings.meeting_reschedule_requested.field.new_slot_end, event.meetings.meeting_moved_in_calendar.field.new_slot_end]
    target      = readmodel.hosted_meetings.field.slot_end
  }

  field_source {
    description = "Active once confirmed, then canceled or completed by the latest of these events."
    inputs      = [event.meetings.meeting_confirmed.field.meeting_id, event.meetings.meeting_canceled.field.meeting_id, event.meetings.meeting_completed.field.meeting_id]
    target      = readmodel.hosted_meetings.field.meeting_status
  }

  scenario "no_bookings_yet" {
    empty_history = true

    then {
      expect_empty_list = true
      readmodel         = readmodel.hosted_meetings
    }
  }

  scenario "confirmed_meeting_is_active" {
    case = "appear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    then {
      examples  = [{ meeting_status = "active" }]
      readmodel = readmodel.hosted_meetings
    }
  }

  scenario "canceled_meeting_is_marked_canceled" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_canceled
    }

    then {
      examples  = [{ meeting_status = "canceled" }]
      readmodel = readmodel.hosted_meetings
    }
  }

  scenario "finished_meeting_is_marked_completed" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_completed
    }

    then {
      examples  = [{ meeting_status = "completed" }]
      readmodel = readmodel.hosted_meetings
    }
  }

  scenario "rescheduled_meeting_shows_the_new_time" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.meeting_rescheduled
    }

    then {
      readmodel = readmodel.hosted_meetings
    }
  }

  scenario "direct_move_shows_the_new_time" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_moved_in_calendar
    }

    then {
      readmodel = readmodel.hosted_meetings
    }
  }
}

state_view "view_my_booked_meetings" {
  description = "Meetings the employee booked with colleagues, so that a booker can reach and manage them. A row appears when the meeting is confirmed."
  status      = "created"

  readmodel "my_booked_meetings" {
    question = "Which meetings have I booked, and what is their status?"
    fields   = [field_type.meetings.meeting_id, field_type.meetings.booker_id, field_type.host_setup.meeting_title, field_type.meetings.slot_start, field_type.meetings.slot_end, field_type.meetings.participants, field_type.meetings.meeting_status]
    from = [
      event.meetings.meeting_slot_reserved,
      event.meetings.meeting_confirmed,
      event.meetings.meeting_reschedule_requested,
      event.meetings.meeting_rescheduled,
      event.meetings.meeting_moved_in_calendar,
      event.meetings.meeting_canceled,
      event.meetings.meeting_completed,
    ]
    to = [screen.my_booked_meetings]
  }

  screen "my_booked_meetings" {
    actor  = actor.meeting_booker
    fields = [field_type.meetings.meeting_id, field_type.host_setup.meeting_title, field_type.meetings.slot_start, field_type.meetings.slot_end, field_type.meetings.participants, field_type.meetings.meeting_status]
  }

  field_source {
    description = "The latest of the meeting's time facts decides: the reserved slot, then the slot of the latest completed reschedule or direct calendar move."
    inputs      = [event.meetings.meeting_slot_reserved.field.slot_start, event.meetings.meeting_reschedule_requested.field.new_slot_start, event.meetings.meeting_moved_in_calendar.field.new_slot_start]
    target      = readmodel.my_booked_meetings.field.slot_start
  }

  field_source {
    description = "The latest of the meeting's time facts decides: the reserved slot, then the slot of the latest completed reschedule or direct calendar move."
    inputs      = [event.meetings.meeting_slot_reserved.field.slot_end, event.meetings.meeting_reschedule_requested.field.new_slot_end, event.meetings.meeting_moved_in_calendar.field.new_slot_end]
    target      = readmodel.my_booked_meetings.field.slot_end
  }

  field_source {
    description = "Active once confirmed, then canceled or completed by the latest of these events."
    inputs      = [event.meetings.meeting_confirmed.field.meeting_id, event.meetings.meeting_canceled.field.meeting_id, event.meetings.meeting_completed.field.meeting_id]
    target      = readmodel.my_booked_meetings.field.meeting_status
  }

  scenario "no_booked_meetings_yet" {
    empty_history = true

    then {
      expect_empty_list = true
      readmodel         = readmodel.my_booked_meetings
    }
  }

  scenario "booked_meeting_appears" {
    case = "appear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    then {
      readmodel = readmodel.my_booked_meetings
    }
  }

  scenario "canceled_meeting_is_marked_canceled" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_canceled
    }

    then {
      examples  = [{ meeting_status = "canceled" }]
      readmodel = readmodel.my_booked_meetings
    }
  }
}

state_view "view_meeting_details" {
  description = "One meeting, for a participant. Rescheduling and canceling start from here. The screen shows a failed change so that the requester knows the meeting did not change."
  status      = "created"

  readmodel "meeting_details" {
    question = "What are the details of this meeting, and did my last change go through?"
    fields   = [field_type.meetings.meeting_id, field_type.host_setup.meeting_type_id, field_type.host_setup.meeting_title, field_type.host_setup.meeting_location, field_type.meetings.slot_start, field_type.meetings.slot_end, field_type.meetings.participants, field_type.meetings.meeting_status, field_type.meetings.failure_reason]
    from = [
      event.meetings.meeting_slot_reserved,
      event.meetings.meeting_confirmed,
      event.meetings.meeting_reschedule_requested,
      event.meetings.meeting_rescheduled,
      event.meetings.meeting_moved_in_calendar,
      event.meetings.meeting_reschedule_failed,
      event.meetings.meeting_cancellation_requested,
      event.meetings.meeting_canceled,
      event.meetings.meeting_cancellation_failed,
      event.meetings.meeting_completed,
    ]
    to = [screen.meeting_details]
  }

  screen "meeting_details" {
    actor  = actor.meeting_participant
    fields = [field_type.meetings.meeting_id, field_type.host_setup.meeting_title, field_type.host_setup.meeting_location, field_type.meetings.slot_start, field_type.meetings.slot_end, field_type.meetings.participants, field_type.meetings.meeting_status, field_type.meetings.failure_reason]
  }

  field_source {
    description = "The latest of the meeting's time facts decides: the reserved slot, then the slot of the latest completed reschedule or direct calendar move."
    inputs      = [event.meetings.meeting_slot_reserved.field.slot_start, event.meetings.meeting_reschedule_requested.field.new_slot_start, event.meetings.meeting_moved_in_calendar.field.new_slot_start]
    target      = readmodel.meeting_details.field.slot_start
  }

  field_source {
    description = "The latest of the meeting's time facts decides: the reserved slot, then the slot of the latest completed reschedule or direct calendar move."
    inputs      = [event.meetings.meeting_slot_reserved.field.slot_end, event.meetings.meeting_reschedule_requested.field.new_slot_end, event.meetings.meeting_moved_in_calendar.field.new_slot_end]
    target      = readmodel.meeting_details.field.slot_end
  }

  field_source {
    description = "Active, change in progress, canceled, or completed, by the latest of these events."
    inputs      = [event.meetings.meeting_confirmed.field.meeting_id, event.meetings.meeting_reschedule_requested.field.meeting_id, event.meetings.meeting_cancellation_requested.field.meeting_id, event.meetings.meeting_canceled.field.meeting_id, event.meetings.meeting_completed.field.meeting_id]
    target      = readmodel.meeting_details.field.meeting_status
  }

  scenario "confirmed_meeting_details_appear" {
    case = "appear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    then {
      readmodel = readmodel.meeting_details
    }
  }

  scenario "failed_reschedule_keeps_the_original_time" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.meeting_reschedule_failed
    }

    then {
      readmodel = readmodel.meeting_details
    }
  }

  scenario "failed_cancellation_keeps_the_meeting" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_cancellation_requested
    }

    given {
      event = event.meetings.meeting_cancellation_failed
    }

    then {
      readmodel = readmodel.meeting_details
    }
  }

  scenario "direct_move_shows_the_new_time" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_moved_in_calendar
    }

    then {
      readmodel = readmodel.meeting_details
    }
  }
}

state_change "request_meeting_reschedule" {
  description = "A participant picks a different available slot. Revalidates the new slot like a new booking."
  status      = "created"

  screen "confirm_new_slot" {
    actor  = actor.meeting_participant
    fields = [field_type.meetings.meeting_id, field_type.meetings.new_slot_start, field_type.meetings.new_slot_end]
    to     = [command.request_meeting_reschedule]
  }

  command "request_meeting_reschedule" {
    aggregate              = aggregate.meetings.meeting
    aggregate_dependencies = [aggregate.host_setup.meeting_type, aggregate.host_setup.availability_schedule, aggregate.host_setup.calendar_connection]
    fields                 = [field_type.meetings.meeting_id, field_type.meetings.new_slot_start, field_type.meetings.new_slot_end]
    to                     = [event.meetings.meeting_reschedule_requested]

    field "host_id" {
      type      = field_type.host_setup.host_id
      generated = true
    }

    field "requested_by" {
      type      = field_type.meetings.requested_by
      generated = true
    }

    field "calendar_event_id" {
      type      = field_type.meetings.calendar_event_id
      generated = true
    }

    field "participants" {
      type      = field_type.meetings.participants
      generated = true
    }
  }

  scenario "participant_requests_a_new_time" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    when {
      command = command.request_meeting_reschedule
    }

    then {
      event = event.meetings.meeting_reschedule_requested
    }
  }

  scenario "new_slot_already_taken_is_refused" {
    case = "state_violation"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_slot_reserved
    }

    when {
      command = command.request_meeting_reschedule
    }

    then {
      error = "This time is no longer available. Please choose another slot."
    }
  }

  scenario "canceled_meeting_cannot_be_rescheduled" {
    case = "state_violation"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_canceled
    }

    when {
      command = command.request_meeting_reschedule
    }

    then {
      error = "A meeting that has ended or was canceled cannot be rescheduled."
    }
  }

  scenario "completed_meeting_cannot_be_rescheduled" {
    case = "state_violation"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_completed
    }

    when {
      command = command.request_meeting_reschedule
    }

    then {
      error = "A meeting that has ended or was canceled cannot be rescheduled."
    }
  }

  scenario "second_change_waits_for_the_first" {
    case = "state_violation"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    when {
      command = command.request_meeting_reschedule
    }

    then {
      error = "Another change to this meeting is still in progress."
    }
  }

  scenario "non_participant_is_refused" {
    case = "authorization"

    given {
      event = event.meetings.meeting_confirmed
    }

    when {
      command = command.request_meeting_reschedule
    }

    then {
      error = "Only the participants of this meeting can change it."
    }
  }

  scenario "meeting_of_a_deleted_type_can_get_a_new_time" {
    case = "variant"

    given {
      event = event.host_setup.meeting_type_deleted
    }

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    when {
      command = command.request_meeting_reschedule
    }

    then {
      event = event.meetings.meeting_reschedule_requested
    }
  }
}

automation "request_reschedule_availability_check" {
  description = "Worker. Asks the calendar system whether the host is free for the new slot, right now. Only free/busy data is asked for."
  status      = "created"

  readmodel "reschedules_awaiting_live_check" {
    question = "Which requested new times still need a live check of the host's calendar?"
    fields   = [field_type.meetings.meeting_id, field_type.host_setup.host_id, field_type.meetings.new_slot_start, field_type.meetings.new_slot_end]
    from     = [event.meetings.meeting_reschedule_requested, event.meetings.reschedule_availability_check_requested, event.meetings.meeting_moved_in_calendar, event.meetings.meeting_canceled]
    to       = [processor.reschedule_check_requester]
  }

  processor "reschedule_check_requester" {
    fields = [field_type.meetings.meeting_id, field_type.host_setup.host_id, field_type.meetings.new_slot_start, field_type.meetings.new_slot_end]
    to     = [command.request_reschedule_availability_check]
  }

  command "request_reschedule_availability_check" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id, field_type.host_setup.host_id, field_type.meetings.new_slot_start, field_type.meetings.new_slot_end]
    to        = [event.meetings.reschedule_availability_check_requested]
  }

  scenario "check_is_requested" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      readmodel = readmodel.reschedules_awaiting_live_check
    }

    when {
      processor = processor.reschedule_check_requester
    }

    then {
      event = event.meetings.reschedule_availability_check_requested
    }
  }

  scenario "held_slot_waits_for_its_check" {
    case = "appear"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    then {
      readmodel = readmodel.reschedules_awaiting_live_check
    }
  }

  scenario "requested_check_leaves_the_list" {
    case = "disappear"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.reschedule_availability_check_requested
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.reschedules_awaiting_live_check
    }
  }

  scenario "direct_move_stops_the_check" {
    description = "The calendar wins, so the reschedule in progress is replaced."
    case        = "disappear"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.meeting_moved_in_calendar
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.reschedules_awaiting_live_check
    }
  }

  scenario "direct_deletion_stops_the_check" {
    case = "disappear"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.meeting_canceled
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.reschedules_awaiting_live_check
    }
  }
}

automation "verify_rescheduled_slot" {
  description = "Translation. The calendar system reports that the host is free for the new slot."
  status      = "created"

  readmodel "free_answers_for_reschedules" {
    question = "For which new times has the calendar system confirmed that the host is free?"
    fields   = [field_type.meetings.meeting_id]
    from     = [event.corporate_calendar.host_slot_found_free, event.meetings.reschedule_availability_check_requested]
    to       = [processor.reschedule_free_translator]
  }

  processor "reschedule_free_translator" {
    fields = [field_type.meetings.meeting_id]
    to     = [command.record_new_slot_verified]
  }

  command "record_new_slot_verified" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id]
    to        = [event.meetings.new_slot_verified]
  }

  field_source {
    description = "The meeting named in the answer. The request lists only the answers that belong to this kind of check."
    inputs      = [event.corporate_calendar.host_slot_found_free.field.scheduler_meeting_ref, event.meetings.reschedule_availability_check_requested.field.meeting_id]
    target      = readmodel.free_answers_for_reschedules.field.meeting_id
  }

  scenario "free_host_verifies_the_slot" {
    case = "happy_path"

    given {
      event = event.meetings.reschedule_availability_check_requested
    }

    given {
      event = event.corporate_calendar.host_slot_found_free
    }

    when {
      processor = processor.reschedule_free_translator
    }

    then {
      event = event.meetings.new_slot_verified
    }
  }

  scenario "free_answer_is_listed" {
    case = "appear"

    given {
      event = event.meetings.reschedule_availability_check_requested
    }

    given {
      event = event.corporate_calendar.host_slot_found_free
    }

    then {
      readmodel = readmodel.free_answers_for_reschedules
    }
  }
}

automation "request_calendar_event_update" {
  description = "Worker. Once the live check has passed, asks the calendar system to move the event."
  status      = "created"

  readmodel "reschedules_awaiting_calendar_update" {
    question = "Which verified reschedules still need a calendar update?"
    fields   = [field_type.meetings.meeting_id, field_type.meetings.new_slot_start, field_type.meetings.new_slot_end, field_type.meetings.calendar_event_id]
    from     = [event.meetings.meeting_reschedule_requested, event.meetings.new_slot_verified, event.meetings.calendar_event_update_requested, event.meetings.meeting_moved_in_calendar, event.meetings.meeting_canceled]
    to       = [processor.calendar_update_requester]
  }

  processor "calendar_update_requester" {
    fields = [field_type.meetings.meeting_id, field_type.meetings.new_slot_start, field_type.meetings.new_slot_end, field_type.meetings.calendar_event_id]
    to     = [command.request_calendar_event_update]
  }

  command "request_calendar_event_update" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id, field_type.meetings.new_slot_start]
    to        = [event.meetings.calendar_event_update_requested]
  }

  scenario "reschedule_requests_a_calendar_update" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.new_slot_verified
    }

    given {
      readmodel = readmodel.reschedules_awaiting_calendar_update
    }

    when {
      processor = processor.calendar_update_requester
    }

    then {
      event = event.meetings.calendar_event_update_requested
    }
  }

  scenario "reschedule_waits_for_its_update" {
    case = "appear"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.new_slot_verified
    }

    then {
      readmodel = readmodel.reschedules_awaiting_calendar_update
    }
  }

  scenario "requested_update_leaves_the_list" {
    case = "disappear"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.new_slot_verified
    }

    given {
      event = event.meetings.calendar_event_update_requested
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.reschedules_awaiting_calendar_update
    }
  }

  scenario "unchecked_reschedule_is_not_requested" {
    case = "disappear"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.reschedules_awaiting_calendar_update
    }
  }

  scenario "direct_move_stops_the_update" {
    description = "The calendar wins, so the reschedule in progress is replaced."
    case        = "disappear"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.new_slot_verified
    }

    given {
      event = event.meetings.meeting_moved_in_calendar
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.reschedules_awaiting_calendar_update
    }
  }

  scenario "direct_deletion_stops_the_update" {
    case = "disappear"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.new_slot_verified
    }

    given {
      event = event.meetings.meeting_canceled
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.reschedules_awaiting_calendar_update
    }
  }
}

automation "complete_meeting_reschedule" {
  description = "Translation. The calendar event has moved, so both participants' calendars show the new time."
  status      = "created"

  readmodel "updated_calendar_events" {
    question = "Which meetings has the calendar system moved?"
    fields   = [field_type.meetings.meeting_id]
    from     = [event.corporate_calendar.calendar_event_updated]
    to       = [processor.calendar_updated_translator]
  }

  processor "calendar_updated_translator" {
    fields = [field_type.meetings.meeting_id]
    to     = [command.complete_reschedule]
  }

  command "complete_reschedule" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id]
    to        = [event.meetings.meeting_rescheduled]
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_event_updated.field.scheduler_meeting_ref]
    target = readmodel.updated_calendar_events.field.meeting_id
  }

  scenario "moved_event_completes_the_reschedule" {
    case = "happy_path"

    given {
      event = event.meetings.calendar_event_update_requested
    }

    given {
      event = event.corporate_calendar.calendar_event_updated
    }

    when {
      processor = processor.calendar_updated_translator
    }

    then {
      event = event.meetings.meeting_rescheduled
    }
  }

  scenario "moved_event_is_listed" {
    case = "appear"

    given {
      event = event.corporate_calendar.calendar_event_updated
    }

    then {
      readmodel = readmodel.updated_calendar_events
    }
  }
}

automation "fail_meeting_reschedule" {
  description = "Translation. The live check found the host busy or could not be answered, or the calendar system could not move the event. The meeting keeps its original time and the participant can try again. There is no automatic retry."
  status      = "created"

  readmodel "failed_calendar_updates" {
    question = "Which reschedules failed their live check, or could the calendar system not move?"
    fields   = [field_type.meetings.meeting_id, field_type.meetings.failure_reason]
    from     = [event.corporate_calendar.calendar_event_update_failed, event.corporate_calendar.host_slot_found_busy, event.corporate_calendar.availability_check_failed, event.meetings.reschedule_availability_check_requested]
    to       = [processor.calendar_update_failure_translator]
  }

  processor "calendar_update_failure_translator" {
    fields = [field_type.meetings.meeting_id, field_type.meetings.failure_reason]
    to     = [command.fail_reschedule]
  }

  command "fail_reschedule" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id, field_type.meetings.failure_reason]
    to        = [event.meetings.meeting_reschedule_failed]
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_event_update_failed.field.scheduler_meeting_ref, event.corporate_calendar.host_slot_found_busy.field.scheduler_meeting_ref, event.corporate_calendar.availability_check_failed.field.scheduler_meeting_ref]
    target = readmodel.failed_calendar_updates.field.meeting_id
  }

  field_source {
    description = "A busy answer gives 'This time is no longer available. Please choose another slot.' A failed check gives 'The host's availability cannot be verified right now. Please try again later.' A refused calendar change keeps its failure code."
    inputs      = [event.corporate_calendar.calendar_event_update_failed.field.failure_code, event.corporate_calendar.host_slot_found_busy.field.scheduler_meeting_ref, event.corporate_calendar.availability_check_failed.field.failure_code]
    target      = readmodel.failed_calendar_updates.field.failure_reason
  }

  scenario "update_failure_keeps_the_original_time" {
    case = "external_failure"

    given {
      event = event.meetings.calendar_event_update_requested
    }

    given {
      event = event.corporate_calendar.calendar_event_update_failed
    }

    when {
      processor = processor.calendar_update_failure_translator
    }

    then {
      event = event.meetings.meeting_reschedule_failed
    }
  }

  scenario "update_failure_is_listed" {
    case = "appear"

    given {
      event = event.corporate_calendar.calendar_event_update_failed
    }

    then {
      readmodel = readmodel.failed_calendar_updates
    }
  }

  scenario "busy_host_keeps_the_original_time" {
    case = "external_failure"

    given {
      event = event.meetings.reschedule_availability_check_requested
    }

    given {
      event = event.corporate_calendar.host_slot_found_busy
    }

    when {
      processor = processor.calendar_update_failure_translator
    }

    then {
      event = event.meetings.meeting_reschedule_failed
    }
  }

  scenario "unanswered_check_keeps_the_original_time" {
    case = "external_failure"

    given {
      event = event.meetings.reschedule_availability_check_requested
    }

    given {
      event = event.corporate_calendar.availability_check_failed
    }

    when {
      processor = processor.calendar_update_failure_translator
    }

    then {
      event = event.meetings.meeting_reschedule_failed
    }
  }
}

automation "apply_direct_calendar_move" {
  description = "Translation. Someone moved the event directly in the calendar, and the meeting follows it. The calendar wins, so this replaces a reschedule in progress and takes the moved time even if it falls outside the host's rules."
  status      = "created"

  readmodel "direct_calendar_moves" {
    question = "Which meetings were moved directly in the calendar?"
    fields   = [field_type.meetings.meeting_id, field_type.meetings.new_slot_start, field_type.meetings.new_slot_end]
    from     = [event.corporate_calendar.calendar_event_moved_directly]
    to       = [processor.direct_move_translator]
  }

  processor "direct_move_translator" {
    fields = [field_type.meetings.meeting_id, field_type.meetings.new_slot_start, field_type.meetings.new_slot_end]
    to     = [command.record_meeting_moved]
  }

  command "record_meeting_moved" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id, field_type.meetings.new_slot_start, field_type.meetings.new_slot_end]
    to        = [event.meetings.meeting_moved_in_calendar]
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_event_moved_directly.field.scheduler_meeting_ref]
    target = readmodel.direct_calendar_moves.field.meeting_id
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_event_moved_directly.field.moved_start]
    target = readmodel.direct_calendar_moves.field.new_slot_start
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_event_moved_directly.field.moved_end]
    target = readmodel.direct_calendar_moves.field.new_slot_end
  }

  scenario "direct_move_reschedules_the_meeting" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.corporate_calendar.calendar_event_moved_directly
    }

    when {
      processor = processor.direct_move_translator
    }

    then {
      event = event.meetings.meeting_moved_in_calendar
    }
  }

  scenario "direct_move_replaces_a_reschedule_in_progress" {
    case = "variant"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.corporate_calendar.calendar_event_moved_directly
    }

    when {
      processor = processor.direct_move_translator
    }

    then {
      event = event.meetings.meeting_moved_in_calendar
    }
  }

  scenario "direct_move_during_a_cancellation_is_dropped" {
    case = "state_violation"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_cancellation_requested
    }

    given {
      event = event.corporate_calendar.calendar_event_moved_directly
    }

    when {
      processor = processor.direct_move_translator
    }

    then {
      expect_no_dispatch = true
      command            = command.record_meeting_moved
    }
  }

  scenario "direct_move_after_the_end_is_dropped" {
    case = "state_violation"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_completed
    }

    given {
      event = event.corporate_calendar.calendar_event_moved_directly
    }

    when {
      processor = processor.direct_move_translator
    }

    then {
      expect_no_dispatch = true
      command            = command.record_meeting_moved
    }
  }

  scenario "direct_move_is_listed" {
    case = "appear"

    given {
      event = event.corporate_calendar.calendar_event_moved_directly
    }

    then {
      readmodel = readmodel.direct_calendar_moves
    }
  }
}

automation "send_reschedule_notice" {
  description = "Worker. Both participants are told about the new time by email, also after a direct move in the calendar."
  status      = "created"

  readmodel "reschedule_notices_to_send" {
    question = "Which completed reschedules and direct calendar moves have not yet been announced to both participants?"
    fields   = [field_type.meetings.meeting_id, field_type.meetings.new_slot_start, field_type.meetings.participants]
    from     = [event.meetings.meeting_slot_reserved, event.meetings.meeting_reschedule_requested, event.meetings.meeting_rescheduled, event.meetings.meeting_moved_in_calendar, event.meetings.reschedule_notice_sent]
    to       = [processor.reschedule_notifier]
  }

  processor "reschedule_notifier" {
    fields = [field_type.meetings.meeting_id, field_type.meetings.new_slot_start, field_type.meetings.participants]
    to     = [command.send_reschedule_notice]
  }

  command "send_reschedule_notice" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id, field_type.meetings.new_slot_start, field_type.meetings.participants]
    to        = [event.meetings.reschedule_notice_sent]
  }

  scenario "completed_reschedule_is_announced" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.meeting_rescheduled
    }

    given {
      readmodel = readmodel.reschedule_notices_to_send
    }

    when {
      processor = processor.reschedule_notifier
    }

    then {
      event = event.meetings.reschedule_notice_sent
    }
  }

  scenario "completed_reschedule_waits_for_announcement" {
    case = "appear"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.meeting_rescheduled
    }

    then {
      readmodel = readmodel.reschedule_notices_to_send
    }
  }

  scenario "announced_reschedule_leaves_the_list" {
    case = "disappear"

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.meetings.meeting_rescheduled
    }

    given {
      event = event.meetings.reschedule_notice_sent
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.reschedule_notices_to_send
    }
  }

  scenario "direct_move_is_announced" {
    case = "variant"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_moved_in_calendar
    }

    when {
      processor = processor.reschedule_notifier
    }

    then {
      event = event.meetings.reschedule_notice_sent
    }
  }
}

state_change "request_meeting_cancellation" {
  status = "created"

  screen "confirm_cancellation" {
    actor  = actor.meeting_participant
    fields = [field_type.meetings.meeting_id]
    to     = [command.request_meeting_cancellation]
  }

  command "request_meeting_cancellation" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id]
    to        = [event.meetings.meeting_cancellation_requested]

    field "host_id" {
      type      = field_type.host_setup.host_id
      generated = true
    }

    field "requested_by" {
      type      = field_type.meetings.requested_by
      generated = true
    }

    field "calendar_event_id" {
      type      = field_type.meetings.calendar_event_id
      generated = true
    }

    field "participants" {
      type      = field_type.meetings.participants
      generated = true
    }
  }

  scenario "participant_requests_cancellation" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    when {
      command = command.request_meeting_cancellation
    }

    then {
      event = event.meetings.meeting_cancellation_requested
    }
  }

  scenario "canceled_meeting_cannot_be_canceled_again" {
    case = "state_violation"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_canceled
    }

    when {
      command = command.request_meeting_cancellation
    }

    then {
      error = "A meeting that has ended or was canceled cannot be canceled."
    }
  }

  scenario "completed_meeting_cannot_be_canceled" {
    case = "state_violation"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_completed
    }

    when {
      command = command.request_meeting_cancellation
    }

    then {
      error = "A meeting that has ended or was canceled cannot be canceled."
    }
  }

  scenario "cancellation_waits_for_a_running_change" {
    case = "state_violation"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    when {
      command = command.request_meeting_cancellation
    }

    then {
      error = "Another change to this meeting is still in progress."
    }
  }

  scenario "non_participant_is_refused" {
    case = "authorization"

    given {
      event = event.meetings.meeting_confirmed
    }

    when {
      command = command.request_meeting_cancellation
    }

    then {
      error = "Only the participants of this meeting can change it."
    }
  }
}

automation "request_calendar_event_deletion" {
  description = "Worker. Asks the calendar system to remove the event."
  status      = "created"

  readmodel "cancellations_awaiting_calendar_deletion" {
    question = "Which requested cancellations still need the calendar event removed?"
    fields   = [field_type.meetings.meeting_id, field_type.meetings.calendar_event_id]
    from     = [event.meetings.meeting_cancellation_requested, event.meetings.calendar_event_deletion_requested, event.meetings.meeting_canceled]
    to       = [processor.calendar_deletion_requester]
  }

  processor "calendar_deletion_requester" {
    fields = [field_type.meetings.meeting_id, field_type.meetings.calendar_event_id]
    to     = [command.request_calendar_event_deletion]
  }

  command "request_calendar_event_deletion" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id]
    to        = [event.meetings.calendar_event_deletion_requested]
  }

  scenario "cancellation_requests_calendar_deletion" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_cancellation_requested
    }

    given {
      readmodel = readmodel.cancellations_awaiting_calendar_deletion
    }

    when {
      processor = processor.calendar_deletion_requester
    }

    then {
      event = event.meetings.calendar_event_deletion_requested
    }
  }

  scenario "cancellation_waits_for_deletion" {
    case = "appear"

    given {
      event = event.meetings.meeting_cancellation_requested
    }

    then {
      readmodel = readmodel.cancellations_awaiting_calendar_deletion
    }
  }

  scenario "requested_deletion_leaves_the_list" {
    case = "disappear"

    given {
      event = event.meetings.meeting_cancellation_requested
    }

    given {
      event = event.meetings.calendar_event_deletion_requested
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.cancellations_awaiting_calendar_deletion
    }
  }

  scenario "direct_deletion_stops_the_request" {
    description = "The event is already gone from the calendar."
    case        = "disappear"

    given {
      event = event.meetings.meeting_cancellation_requested
    }

    given {
      event = event.meetings.meeting_canceled
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.cancellations_awaiting_calendar_deletion
    }
  }
}

automation "complete_meeting_cancellation" {
  description = "Translation. The calendar event is gone, so the meeting is canceled and its slot is released."
  status      = "created"

  readmodel "deleted_calendar_events" {
    question = "Which meetings has the calendar system removed?"
    fields   = [field_type.meetings.meeting_id]
    from     = [event.corporate_calendar.calendar_event_deleted]
    to       = [processor.calendar_deleted_translator]
  }

  processor "calendar_deleted_translator" {
    fields = [field_type.meetings.meeting_id]
    to     = [command.complete_cancellation]
  }

  command "complete_cancellation" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id]
    to        = [event.meetings.meeting_canceled]
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_event_deleted.field.scheduler_meeting_ref]
    target = readmodel.deleted_calendar_events.field.meeting_id
  }

  scenario "deleted_event_cancels_the_meeting" {
    case = "happy_path"

    given {
      event = event.meetings.calendar_event_deletion_requested
    }

    given {
      event = event.corporate_calendar.calendar_event_deleted
    }

    when {
      processor = processor.calendar_deleted_translator
    }

    then {
      event = event.meetings.meeting_canceled
    }
  }

  scenario "deleted_event_is_listed" {
    case = "appear"

    given {
      event = event.corporate_calendar.calendar_event_deleted
    }

    then {
      readmodel = readmodel.deleted_calendar_events
    }
  }
}

automation "fail_meeting_cancellation" {
  description = "Translation. The calendar system could not remove the event, so the meeting stays confirmed."
  status      = "created"

  readmodel "failed_calendar_deletions" {
    question = "Which meetings could the calendar system not remove?"
    fields   = [field_type.meetings.meeting_id, field_type.meetings.failure_reason]
    from     = [event.corporate_calendar.calendar_event_deletion_failed]
    to       = [processor.calendar_deletion_failure_translator]
  }

  processor "calendar_deletion_failure_translator" {
    fields = [field_type.meetings.meeting_id, field_type.meetings.failure_reason]
    to     = [command.fail_cancellation]
  }

  command "fail_cancellation" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id, field_type.meetings.failure_reason]
    to        = [event.meetings.meeting_cancellation_failed]
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_event_deletion_failed.field.scheduler_meeting_ref]
    target = readmodel.failed_calendar_deletions.field.meeting_id
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_event_deletion_failed.field.failure_code]
    target = readmodel.failed_calendar_deletions.field.failure_reason
  }

  scenario "deletion_failure_keeps_the_meeting" {
    case = "external_failure"

    given {
      event = event.meetings.calendar_event_deletion_requested
    }

    given {
      event = event.corporate_calendar.calendar_event_deletion_failed
    }

    when {
      processor = processor.calendar_deletion_failure_translator
    }

    then {
      event = event.meetings.meeting_cancellation_failed
    }
  }

  scenario "deletion_failure_is_listed" {
    case = "appear"

    given {
      event = event.corporate_calendar.calendar_event_deletion_failed
    }

    then {
      readmodel = readmodel.failed_calendar_deletions
    }
  }
}

automation "apply_direct_calendar_deletion" {
  description = "Translation. Someone deleted the event directly in the calendar, and the meeting counts as canceled. The calendar wins, so this also ends a reschedule or cancellation in progress."
  status      = "created"

  readmodel "direct_calendar_deletions" {
    question = "Which meetings were deleted directly in the calendar?"
    fields   = [field_type.meetings.meeting_id]
    from     = [event.corporate_calendar.calendar_event_deleted_directly]
    to       = [processor.direct_deletion_translator]
  }

  processor "direct_deletion_translator" {
    fields = [field_type.meetings.meeting_id]
    to     = [command.record_meeting_deleted]
  }

  command "record_meeting_deleted" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id]
    to        = [event.meetings.meeting_canceled]
  }

  field_source {
    inputs = [event.corporate_calendar.calendar_event_deleted_directly.field.scheduler_meeting_ref]
    target = readmodel.direct_calendar_deletions.field.meeting_id
  }

  scenario "direct_deletion_cancels_the_meeting" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.corporate_calendar.calendar_event_deleted_directly
    }

    when {
      processor = processor.direct_deletion_translator
    }

    then {
      event = event.meetings.meeting_canceled
    }
  }

  scenario "direct_deletion_ends_a_reschedule_in_progress" {
    case = "variant"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_reschedule_requested
    }

    given {
      event = event.corporate_calendar.calendar_event_deleted_directly
    }

    when {
      processor = processor.direct_deletion_translator
    }

    then {
      event = event.meetings.meeting_canceled
    }
  }

  scenario "direct_deletion_after_the_end_is_dropped" {
    case = "state_violation"

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_completed
    }

    given {
      event = event.corporate_calendar.calendar_event_deleted_directly
    }

    when {
      processor = processor.direct_deletion_translator
    }

    then {
      expect_no_dispatch = true
      command            = command.record_meeting_deleted
    }
  }

  scenario "direct_deletion_is_listed" {
    case = "appear"

    given {
      event = event.corporate_calendar.calendar_event_deleted_directly
    }

    then {
      readmodel = readmodel.direct_calendar_deletions
    }
  }
}

automation "send_cancellation_notice" {
  description = "Worker. Both participants are told by email that the meeting is canceled, also after a direct deletion in the calendar."
  status      = "created"

  readmodel "cancellation_notices_to_send" {
    question = "Which canceled meetings have not yet been announced to both participants?"
    fields   = [field_type.meetings.meeting_id, field_type.meetings.participants]
    from     = [event.meetings.meeting_slot_reserved, event.meetings.meeting_cancellation_requested, event.meetings.meeting_canceled, event.meetings.cancellation_notice_sent]
    to       = [processor.cancellation_notifier]
  }

  processor "cancellation_notifier" {
    fields = [field_type.meetings.meeting_id, field_type.meetings.participants]
    to     = [command.send_cancellation_notice]
  }

  command "send_cancellation_notice" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id, field_type.meetings.participants]
    to        = [event.meetings.cancellation_notice_sent]
  }

  scenario "canceled_meeting_is_announced" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_cancellation_requested
    }

    given {
      event = event.meetings.meeting_canceled
    }

    given {
      readmodel = readmodel.cancellation_notices_to_send
    }

    when {
      processor = processor.cancellation_notifier
    }

    then {
      event = event.meetings.cancellation_notice_sent
    }
  }

  scenario "canceled_meeting_waits_for_announcement" {
    case = "appear"

    given {
      event = event.meetings.meeting_cancellation_requested
    }

    given {
      event = event.meetings.meeting_canceled
    }

    then {
      readmodel = readmodel.cancellation_notices_to_send
    }
  }

  scenario "announced_cancellation_leaves_the_list" {
    case = "disappear"

    given {
      event = event.meetings.meeting_cancellation_requested
    }

    given {
      event = event.meetings.meeting_canceled
    }

    given {
      event = event.meetings.cancellation_notice_sent
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.cancellation_notices_to_send
    }
  }

  scenario "direct_deletion_is_announced" {
    case = "variant"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_canceled
    }

    when {
      processor = processor.cancellation_notifier
    }

    then {
      event = event.meetings.cancellation_notice_sent
    }
  }
}

automation "complete_finished_meeting" {
  description = "Worker. Trigger: a confirmed meeting's end time passes. There is no grace period."
  status      = "created"

  readmodel "meetings_to_complete" {
    question = "Which confirmed meetings have not yet been marked completed?"
    fields   = [field_type.meetings.meeting_id, field_type.meetings.slot_end]
    from = [
      event.meetings.meeting_slot_reserved,
      event.meetings.meeting_confirmed,
      event.meetings.meeting_reschedule_requested,
      event.meetings.meeting_rescheduled,
      event.meetings.meeting_moved_in_calendar,
      event.meetings.meeting_canceled,
      event.meetings.meeting_completed,
    ]
    to = [processor.meeting_completer]
  }

  processor "meeting_completer" {
    fields = [field_type.meetings.meeting_id, field_type.meetings.slot_end]
    to     = [command.complete_meeting]
  }

  command "complete_meeting" {
    aggregate = aggregate.meetings.meeting
    fields    = [field_type.meetings.meeting_id]
    to        = [event.meetings.meeting_completed]
  }

  field_source {
    description = "The latest of the meeting's time facts decides: the reserved slot, then the slot of the latest completed reschedule or direct calendar move."
    inputs      = [event.meetings.meeting_slot_reserved.field.slot_end, event.meetings.meeting_reschedule_requested.field.new_slot_end, event.meetings.meeting_moved_in_calendar.field.new_slot_end]
    target      = readmodel.meetings_to_complete.field.slot_end
  }

  scenario "ended_meeting_is_completed" {
    case = "happy_path"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      readmodel = readmodel.meetings_to_complete
    }

    when {
      processor = processor.meeting_completer
    }

    then {
      event = event.meetings.meeting_completed
    }
  }

  scenario "confirmed_meeting_waits_for_its_end" {
    case = "appear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    then {
      readmodel = readmodel.meetings_to_complete
    }
  }

  scenario "canceled_meeting_leaves_the_list" {
    case = "disappear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_canceled
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.meetings_to_complete
    }
  }

  scenario "completed_meeting_leaves_the_list" {
    case = "disappear"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_completed
    }

    then {
      expect_empty_list = true
      readmodel         = readmodel.meetings_to_complete
    }
  }

  scenario "directly_moved_meeting_waits_for_its_new_end" {
    case = "change"

    given {
      event = event.meetings.meeting_slot_reserved
    }

    given {
      event = event.meetings.meeting_confirmed
    }

    given {
      event = event.meetings.meeting_moved_in_calendar
    }

    then {
      readmodel = readmodel.meetings_to_complete
    }
  }
}

evidence_source "epic" {
  kind     = "document"
  location = "EPIC: Self-Service Meeting Scheduling for Employees, supplied in the modeling request"
}

evidence_source "model_owner_answers" {
  kind     = "person"
  location = "Answers from the model owner in the Claude Code session of 2026-11-09"
}

evidence "no_double_booking" {
  certainty = "stated"
  location  = "US-05, section 6 Reliability"
  source    = evidence_source.epic
  on        = workflow.reserve_meeting_slot
}

evidence "failed_connection_offers_nothing" {
  certainty = "stated"
  location  = "US-01"
  source    = evidence_source.epic
  on        = workflow.view_available_slots
}

evidence "free_busy_only" {
  certainty = "stated"
  location  = "section 6 Security & Access"
  source    = evidence_source.epic
  on        = workflow.record_host_busy_times
}

evidence "disabled_types_take_no_bookings" {
  certainty = "stated"
  location  = "US-03, US-04"
  source    = evidence_source.epic
  on        = lifecycle.meeting_type
}

evidence "released_slots_return" {
  certainty = "stated"
  location  = "US-06, section 10"
  source    = evidence_source.epic
  on        = workflow.view_available_slots
}

evidence "one_change_at_a_time" {
  description = "Follows from the requirement to avoid inconsistent application and calendar states. The epic does not state this rule."
  certainty   = "assumed"
  on          = invalid_transition.meeting.reschedule_during_another_change
}

decision "no_overlap_spans_the_host" {
  statement = "The no-overlap check on reserve_meeting_slot and request_meeting_reschedule covers every held slot of the host, across all meetings and meeting types."
  reason    = "Meeting types have different durations, so overlaps cannot be found per slot, and a single meeting stream cannot see other meetings. The meeting stream keeps one lifecycle per meeting, and the check is serialized per host."
  on        = command.reserve_meeting_slot.reserve_meeting_slot
}

decision "reserve_before_calendar" {
  statement = "A booking reserves the slot first and is confirmed only after the calendar system has created the event. Reschedule and cancel follow the same request-then-outcome shape."
  reason    = "The epic requires that booking operations avoid inconsistent application and calendar states. The slot must be held before the outside call, so a concurrent booking cannot take it, and a calendar failure must leave a clear outcome."
  on        = workflow.reserve_meeting_slot
}

decision "slot_calculation_is_one_read_model" {
  kind      = "accepted_debt"
  signal    = "EM403"
  statement = "The available_slots read model reads many events."
  reason    = "The epic defines one calculation that combines working hours, booking restrictions, connected-calendar availability, and existing bookings. Splitting it gives no list that a person or process would use alone."
  on        = readmodel.view_available_slots.available_slots
}

decision "todo_lists_read_open_and_close_events" {
  kind      = "accepted_debt"
  signal    = "EM403"
  statement = "Each worker todo list reads the events that open its work and the event that closes it."
  reason    = "Event Modeling requires the completion event in a worker's todo list. Removing it would leave finished work on the list."
}

decision "status_lists_read_the_meeting_lifecycle" {
  kind      = "accepted_debt"
  signal    = "EM403"
  statement = "Meeting lists and meeting details read several meeting events."
  reason    = "Each list shows the current status of a meeting, and each status comes from a different lifecycle event."
  on        = workflow.view_meeting_details
}

hotspot "free_busy_freshness" {
  status   = "resolved"
  kind     = "assumption"
  category = "rule"
  question = "Is the last reported free/busy data fresh enough to count as revalidating immediately before confirming, or must the scheduler query the calendar live at submission?"
  options = [
    "Use the last reported free/busy data, and rely on the calendar's outcome to catch the remaining gap.",
    "Query free/busy live at submission, which adds a calendar call to the booking step.",
  ]
  on = command.reserve_meeting_slot.reserve_meeting_slot
}

hotspot "notification_channel" {
  status   = "resolved"
  category = "action"
  question = "Which channel carries the confirmation, reschedule, and cancellation notices: email, corporate chat, or only the calendar invitation and its updates?"
  options  = ["Email", "Corporate chat", "Only the calendar invitation and its updates"]
  on       = workflow.send_booking_confirmation
}

hotspot "failed_change_recovery" {
  status   = "resolved"
  kind     = "assumption"
  category = "rule"
  question = "When the calendar refuses a reschedule or a cancellation, should the meeting keep its current state with no automatic retry?"
  options = [
    "Keep the current state, show the failure, and let the participant try again.",
    "Retry automatically for a limited period before reporting failure.",
  ]
  on = workflow.fail_meeting_reschedule
}

hotspot "out_of_band_calendar_changes" {
  status   = "resolved"
  category = "next"
  question = "What happens when a participant deletes or moves the calendar event directly in the calendar system?"
  options = [
    "Treat it as a cancellation or reschedule in the scheduler.",
    "Ignore it, because only the host's free/busy data changes.",
  ]
  on = aggregate.meetings.meeting
}

hotspot "booker_calendar_conflicts" {
  status   = "resolved"
  kind     = "assumption"
  category = "rule"
  question = "Do available slots consider only the host's calendar? The epic's goal mentions a mutually convenient time, but bookers need no setup."
  options = [
    "Only the host's calendar. The booker judges their own availability.",
    "Also check the booker's free/busy data when it is available.",
  ]
  on = workflow.view_available_slots
}

hotspot "authorized_bookers" {
  status   = "resolved"
  kind     = "assumption"
  category = "who"
  question = "Does 'authorized employees' mean every authenticated employee, or can a host or the organization restrict who may use a link?"
  options  = ["Every authenticated employee", "A host-defined or organization-defined group"]
  on       = actor.meeting_booker
}

hotspot "self_booking" {
  status   = "resolved"
  category = "rule"
  question = "May a host book a slot through their own link?"
  options  = ["No, refuse it.", "Yes, allow it."]
  on       = command.reserve_meeting_slot.reserve_meeting_slot
}

hotspot "changes_and_existing_meetings" {
  status   = "resolved"
  kind     = "assumption"
  category = "rule"
  question = "Do edits to a meeting type or availability schedule leave existing meetings unchanged? The model assumes that meetings keep the values captured at booking."
  options = [
    "Existing meetings stay as booked, and changes affect only new bookings.",
    "Existing meetings outside the new rules must be flagged for review.",
  ]
  on = workflow.edit_meeting_type
}

hotspot "delete_with_future_meetings" {
  status   = "resolved"
  category = "rule"
  question = "When a host deletes a meeting type that has upcoming meetings, what happens to those meetings?"
  options = [
    "The meetings remain, and only new bookings stop.",
    "The host must cancel the upcoming meetings first.",
  ]
  on = command.delete_meeting_type.delete_meeting_type
}

hotspot "limits_scope" {
  status   = "resolved"
  kind     = "assumption"
  category = "data"
  question = "Are the booking window, minimum notice, and buffers set per availability schedule? The model assumes so, since meeting types select a schedule."
  options  = ["Per availability schedule", "Per meeting type", "Once per host"]
  on       = workflow.set_booking_limits
}

hotspot "exception_removal" {
  status   = "resolved"
  category = "action"
  question = "Can a host remove or change a date exception after adding it? The epic only states that hosts can create them."
  options  = ["Yes, add remove and change actions.", "No, a newer exception for the date replaces the older one."]
  on       = workflow.add_date_exception
}

hotspot "completion_time" {
  status   = "resolved"
  kind     = "assumption"
  category = "time"
  question = "Does a meeting become completed exactly when its end time passes? The epic only says that completed meetings are distinct."
  options  = ["Yes, at its end time.", "After a grace period."]
  on       = workflow.complete_finished_meeting
}

hotspot "error_wording" {
  status   = "resolved"
  kind     = "assumption"
  category = "example"
  question = "The epic asks for clear errors but gives no wording. Are the drafted messages acceptable, or does a content owner need to supply them?"
  options  = ["Accept the drafted wording.", "A content owner supplies the final wording."]
  on       = workflow.reserve_meeting_slot
}

decision "answer_limits_scope" {
  statement = "The booking window, minimum notice, and buffers are set per availability schedule."
  reason    = "A meeting type gets its limits from the schedule it uses, so a host has fewer settings."
  on        = workflow.set_booking_limits
}

evidence "answer_limits_scope" {
  certainty = "stated"
  location  = "Answer to hotspot limits_scope"
  source    = evidence_source.model_owner_answers
  on        = hotspot.limits_scope
}

decision "answer_exception_removal" {
  statement = "A host can change or remove a date exception after adding it."
  reason    = "A canceled day off must be able to open up again."
  on        = workflow.add_date_exception
}

evidence "answer_exception_removal" {
  certainty = "stated"
  location  = "Answer to hotspot exception_removal"
  source    = evidence_source.model_owner_answers
  on        = hotspot.exception_removal
}

decision "answer_changes_and_existing_meetings" {
  statement = "Edits to a meeting type or an availability schedule leave booked meetings unchanged and affect only new bookings."
  reason    = "An agreed meeting must not move or need attention because of a settings edit."
  on        = workflow.edit_meeting_type
}

evidence "answer_changes_and_existing_meetings" {
  certainty = "stated"
  location  = "Answer to hotspot changes_and_existing_meetings"
  source    = evidence_source.model_owner_answers
  on        = hotspot.changes_and_existing_meetings
}

decision "answer_delete_with_future_meetings" {
  statement = "Deleting a meeting type leaves its upcoming meetings in place. They can still be rescheduled or canceled, and only new bookings stop. A disabled meeting type behaves the same way."
  reason    = "The participants have already agreed on those meetings."
  on        = command.delete_meeting_type.delete_meeting_type
}

evidence "answer_delete_with_future_meetings" {
  certainty = "stated"
  location  = "Answer to hotspot delete_with_future_meetings"
  source    = evidence_source.model_owner_answers
  on        = hotspot.delete_with_future_meetings
}

decision "answer_authorized_bookers" {
  statement = "Every employee who has signed in can use any booking link."
  reason    = "The MVP needs no extra permission setup."
  on        = actor.meeting_booker
}

evidence "answer_authorized_bookers" {
  certainty = "stated"
  location  = "Answer to hotspot authorized_bookers"
  source    = evidence_source.model_owner_answers
  on        = hotspot.authorized_bookers
}

decision "answer_self_booking" {
  statement = "A host cannot book a slot through their own link."
  reason    = "A meeting needs two people."
  on        = command.reserve_meeting_slot.reserve_meeting_slot
}

evidence "answer_self_booking" {
  certainty = "stated"
  location  = "Answer to hotspot self_booking"
  source    = evidence_source.model_owner_answers
  on        = hotspot.self_booking
}

decision "answer_booker_calendar_conflicts" {
  statement = "Available slots consider only the host's calendar. The booker judges their own availability."
  reason    = "Bookers need no setup, and the scheduler needs no access to a booker's calendar."
  on        = workflow.view_available_slots
}

evidence "answer_booker_calendar_conflicts" {
  certainty = "stated"
  location  = "Answer to hotspot booker_calendar_conflicts"
  source    = evidence_source.model_owner_answers
  on        = hotspot.booker_calendar_conflicts
}

decision "answer_free_busy_freshness" {
  statement = "The scheduler asks the host's calendar live before it confirms a booking. The slot is held first, the live check follows, and the calendar event is created only if the host is free."
  reason    = "Calendar systems usually accept an overlapping event, so the calendar's outcome cannot catch a clash. Holding the slot first means that a concurrent booking cannot take it during the check."
  on        = command.reserve_meeting_slot.reserve_meeting_slot
}

evidence "answer_free_busy_freshness" {
  certainty = "stated"
  location  = "Answer to hotspot free_busy_freshness"
  source    = evidence_source.model_owner_answers
  on        = hotspot.free_busy_freshness
}

decision "answer_notification_channel" {
  statement = "Confirmation, reschedule, and cancellation notices go out by email, through a company mail sender."
  reason    = "Everyone has email, and a notice can say why something changed."
  on        = workflow.send_booking_confirmation
}

evidence "answer_notification_channel" {
  certainty = "stated"
  location  = "Answer to hotspot notification_channel"
  source    = evidence_source.model_owner_answers
  on        = hotspot.notification_channel
}

decision "answer_failed_change_recovery" {
  statement = "When a reschedule or cancellation is refused, the meeting keeps its current state, the failure is shown, and the participant can try again. There is no automatic retry."
  reason    = "Nobody is left unsure of the current state of the meeting."
  on        = workflow.fail_meeting_reschedule
}

evidence "answer_failed_change_recovery" {
  certainty = "stated"
  location  = "Answer to hotspot failed_change_recovery"
  source    = evidence_source.model_owner_answers
  on        = hotspot.failed_change_recovery
}

decision "answer_out_of_band_calendar_changes" {
  statement = "The scheduler follows the calendar. Deleting the meeting's event directly in the host's calendar counts as a cancellation, and moving it counts as a reschedule. Both participants are notified."
  reason    = "The epic requires the application and the calendar to stay consistent."
  on        = aggregate.meetings.meeting
}

evidence "answer_out_of_band_calendar_changes" {
  certainty = "stated"
  location  = "Answer to hotspot out_of_band_calendar_changes"
  source    = evidence_source.model_owner_answers
  on        = hotspot.out_of_band_calendar_changes
}

decision "answer_completion_time" {
  statement = "A meeting becomes completed when its end time passes, with no grace period."
  reason    = "The rule is simple and predictable."
  on        = workflow.complete_finished_meeting
}

evidence "answer_completion_time" {
  certainty = "stated"
  location  = "Answer to hotspot completion_time"
  source    = evidence_source.model_owner_answers
  on        = hotspot.completion_time
}

decision "answer_error_wording" {
  statement = "The drafted error messages are the agreed MVP wording."
  reason    = "The epic gives no wording, and a content owner can refine the messages later as a normal change."
  on        = workflow.reserve_meeting_slot
}

evidence "answer_error_wording" {
  certainty = "stated"
  location  = "Answer to hotspot error_wording"
  source    = evidence_source.model_owner_answers
  on        = hotspot.error_wording
}

decision "live_check_covers_reschedules" {
  statement = "A new time picked during a reschedule gets the same live check as a booking."
  reason    = "The model owner chose this. A new time is treated like a new booking."
  on        = workflow.request_reschedule_availability_check
}

decision "calendar_wins_over_changes_in_progress" {
  statement = "A direct deletion always cancels the meeting. A direct move replaces a reschedule in progress. A direct move during a cancellation is dropped. A late calendar answer to a replaced change has no effect."
  reason    = "The model owner chose this, so the two systems disagree for as short a time as possible."
  on        = workflow.apply_direct_calendar_move
}

decision "live_check_answers_read_their_request" {
  kind      = "accepted_debt"
  signal    = "EM403"
  statement = "The lists that translate live check answers read the answer and the request that it belongs to."
  reason    = "The calendar system gives the same answer for a booking and a reschedule. The request tells which kind of check the answer belongs to."
}
