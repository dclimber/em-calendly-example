# EPIC: Self-Service Meeting Scheduling for Employees

**Issue Type:** Epic  
**Priority:** High  
**Product Area:** Internal Productivity Tools  
**Target Release:** MVP  
**Epic Name:** Internal Meeting Scheduler

## 1. Problem Statement

Employees spend unnecessary time coordinating meetings through email, messaging platforms, and manual calendar checks.

Scheduling a simple meeting often requires several interactions to identify a mutually convenient time, confirm availability, create a calendar invitation, and communicate subsequent changes.

We want employees to schedule meetings with colleagues without requiring manual coordination.

## 2. Business Objective

Enable employees to publish their availability through a personal booking link so that colleagues can independently find and book available meeting slots.

The solution must integrate with the company's existing calendar system, automatically prevent conflicting bookings, and manage meeting invitations.

**Expected business value:**
- Reduce time spent coordinating meetings.
- Eliminate unnecessary scheduling conversations.
- Minimize double bookings and calendar conflicts.
- Give employees control over when others can book their time.

## 3. User Personas

**Meeting Host**

An employee who wants others to schedule meetings with them without manually coordinating availability.

**Meeting Booker**

An employee who wants to schedule a meeting with a colleague at a mutually convenient time.

Both users are authenticated employees of the organization.

## 4. Core User Journey

1. An employee signs in using their corporate account.
2. The employee connects their work calendar and configures their preferred meeting availability.
3. The employee creates a meeting type (e.g., "30-minute consultation") and receives a unique booking link.
4. Another employee opens the link and sees the available meeting slots.
5. The booker selects a suitable time and confirms the booking.
6. The system creates a calendar invitation and notifies both participants.
7. Either participant can subsequently cancel or reschedule the meeting.

## 5. Functional Requirements and User Stories

### US-01: Connect Corporate Calendar

**As a** Meeting Host,  
**I want to** connect my corporate calendar,  
**So that** my existing meetings are considered when determining availability.

**Acceptance Criteria:**
- Users can connect their corporate calendar using the organization's approved authentication mechanism.
- The system reads calendar free/busy information.
- Existing busy events are excluded from bookable time slots.
- Newly booked meetings are added to the host's calendar.
- Calendar connection failures are visible to the user and do not result in unverified availability being offered.

### US-02: Configure Meeting Availability

**As a** Meeting Host,  
**I want to** define when I am available for meetings,  
**So that** others can only book time during my preferred working hours.

**Acceptance Criteria:**
- Users can configure recurring availability by weekday and time range.
- Users can create date-specific exceptions, including unavailable days.
- Users can configure a booking window and minimum advance notice.
- Users can define buffer times between meetings.
- Available slots are calculated using configured working hours, booking restrictions, and connected-calendar availability.
- Calendar events marked busy are excluded automatically.
- Meeting times are displayed in the correct local time zone.

### US-03: Create Meeting Types

**As a** Meeting Host,  
**I want to** configure reusable meeting types,  
**So that** colleagues can book meetings of different durations and purposes.

**Acceptance Criteria:**
- Users can create, edit, enable, disable, and delete meeting types.
- Each meeting type contains:
  - Meeting title.
  - Description (optional).
  - Duration (e.g., 15, 30, or 60 minutes).
  - Meeting location or video conferencing link.
  - Applicable availability schedule.
- Every active meeting type receives a unique booking URL.
- Disabled meeting types cannot receive new bookings.

### US-04: Share Booking Links

**As a** Meeting Host,  
**I want to** share a personal meeting booking link,  
**So that** colleagues can schedule meetings without contacting me first.

**Acceptance Criteria:**
- Each meeting type has a stable, shareable URL.
- Opening the URL displays the meeting details and available time slots.
- Users can copy booking links and share them through existing corporate communication tools.
- Booking pages are accessible to authenticated employees without requiring additional setup.
- Only active meeting types can be booked.

### US-05: Book a Meeting

**As a** Meeting Booker,  
**I want to** see available meeting times and select one,  
**So that** I can schedule a meeting without manual coordination.

**Acceptance Criteria:**
- The booking page displays available dates and times.
- Users can select an available slot and review the meeting details.
- The selected slot is revalidated when the booking is submitted.
- The system prevents two bookings through the application from occupying the same host time slot.
- Upon successful booking:
  - A meeting record is created.
  - A calendar event is created with both participants.
  - A calendar invitation is sent.
  - Both participants receive confirmation.
  - The booked time is removed from availability.
- If booking fails, the user receives a clear error and can select another slot.

### US-06: Cancel and Reschedule Meetings

**As a** Meeting Participant,  
**I want to** cancel or reschedule an existing booking,  
**So that** I can manage changes without manually coordinating with the other participant.

**Acceptance Criteria:**
- Participants can access and manage their booked meetings.
- Participants can cancel a booking.
- Participants can select a different available slot to reschedule.
- Changes update the associated calendar event.
- Both participants are notified of changes.
- Canceled or released time slots become available for new bookings if permitted by the availability rules.

### US-07: View Scheduled Meetings

**As a** Meeting Host,  
**I want to** see meetings booked through my scheduling links,  
**So that** I can manage my upcoming appointments.

**Acceptance Criteria:**
- Users can view their upcoming bookings.
- Users can view booking details, including date, time, meeting type, and participants.
- Users can cancel or reschedule bookings from the meeting details.
- The system distinguishes active, canceled, and completed meetings.

## 6. Non-Functional Requirements

**Security & Access**
- The system must integrate with corporate authentication (SSO).
- Booking links must only be usable by authorized employees.
- Calendar event contents must remain private; only free/busy information is exposed when calculating availability.
- Calendar access must use appropriately restricted permissions.

**Reliability**
- The application must revalidate availability immediately before confirming a booking.
- Concurrent booking attempts must not produce duplicate reservations.
- Calendar integration failures must be handled gracefully.
- Booking operations must avoid leaving inconsistent application and calendar states.

**Usability**
- Booking a meeting should require no more than a few straightforward interactions.
- The booking experience must work on desktop and mobile browsers.
- Time-zone differences and daylight-saving changes must be handled correctly.

## 7. Out of Scope — MVP

The following Calendly capabilities are explicitly excluded from this Epic:

- Group meetings with multiple bookers.
- Collective scheduling involving multiple hosts.
- Round-robin team scheduling.
- External customer bookings.
- Advanced routing forms and workflows.
- Payment collection.
- CRM integrations.
- AI scheduling assistants.
- Advanced reporting and analytics.
- SMS reminders and marketing automations.
- Native mobile applications.

These capabilities may be considered in subsequent Epics based on business demand.

## 8. Success Metrics

| Metric | Proposed MVP Target |
|---|---|
| Self-service booking completion rate | ≥ 90% of started bookings |
| Median time to book a meeting | Under 2 minutes |
| Double bookings caused by the application | 0 |
| Calendar event creation success rate | ≥ 99% |
| Scheduling-related manual coordination | Measurable reduction in pilot |

Targets are initial hypotheses to validate during the internal pilot.

## 9. Definition of Done

The Epic is considered complete when:

1. Employees can authenticate and connect their corporate calendars.
2. Hosts can define availability and publish meeting booking links.
3. Colleagues can independently book available one-on-one meeting slots.
4. Bookings automatically create calendar invitations.
5. Both participants can cancel and reschedule meetings.
6. The system handles calendar conflicts, concurrent bookings, time zones, and integration errors.
7. All core scenarios pass acceptance testing.
8. The end-to-end workflow has been validated with an internal pilot group.

## 10. MVP Success Scenario

**Given** Alice has configured a 30-minute meeting type and shared her booking link with Bob,

**And** Alice's calendar contains existing meetings and her preferred working hours,

**When** Bob opens Alice's booking link,

**Then** Bob sees only the available 30-minute slots that satisfy Alice's scheduling rules.

**When** Bob selects an available slot and confirms the booking,

**Then** the system creates a calendar meeting for Alice and Bob, sends invitations, and removes the selected time from Alice's availability.

**When** Bob subsequently reschedules the meeting,

**Then** both participants' calendars reflect the updated time, and the original slot becomes available again.

**Outcome:** Alice and Bob have successfully scheduled and rescheduled a meeting without exchanging messages to coordinate their availability.
