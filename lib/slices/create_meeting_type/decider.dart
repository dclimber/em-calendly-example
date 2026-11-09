import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting_type` aggregate for `create_meeting_type`.
///
/// The `create` transition starts the stream (`before = []`). The model states no invalid transition for this command,
/// so the decider accepts it on an existing meeting type (a lifecycle gap; see the slice report).
final createMeetingTypeDecider = Decider<CreateMeetingTypeCommand, CreateMeetingTypeState, HostSetupEvent>(
  initialState: const CreateMeetingTypeState(),
  decide: (command, state) async* {
    if (state.scheduleOwner != command.hostId) {
      throw const MeetingTypeScheduleMissingError();
    }
    yield MeetingTypeCreatedEvent(
      meetingTypeId: command.meetingTypeId,
      hostId: command.hostId,
      meetingTitle: command.meetingTitle,
      durationMinutes: command.durationMinutes,
      meetingLocation: command.meetingLocation,
      scheduleId: command.scheduleId,
      bookingUrl: command.bookingUrl,
      meetingDescription: command.meetingDescription,
    );
  },
  evolve: (state, event) => switch (event) {
    AvailabilityScheduleCreatedEvent(:final hostId) => CreateMeetingTypeState(
      lifecycle: state.lifecycle,
      scheduleOwner: hostId,
    ),
    MeetingTypeCreatedEvent() => CreateMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.active,
      scheduleOwner: state.scheduleOwner,
    ),
    MeetingTypeEditedEvent() => state,
    MeetingTypeDisabledEvent() => CreateMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.disabled,
      scheduleOwner: state.scheduleOwner,
    ),
    MeetingTypeEnabledEvent() => CreateMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.active,
      scheduleOwner: state.scheduleOwner,
    ),
    MeetingTypeDeletedEvent() => CreateMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.deleted,
      scheduleOwner: state.scheduleOwner,
    ),
    _ => state,
  },
);
