import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting_type` aggregate for `edit_meeting_type`.
///
/// Transitions `edit_active` and `edit_disabled` allow the edit and keep the lifecycle. `edit_deleted` refuses it with
/// the model's text. Booked meetings are not read here, so they stay unchanged (decision
/// `answer_changes_and_existing_meetings`).
final editMeetingTypeDecider = Decider<EditMeetingTypeCommand, EditMeetingTypeState, HostSetupEvent>(
  initialState: const EditMeetingTypeState(),
  decide: (command, state) async* {
    if (state.hostId != command.hostId) throw const NotMeetingTypeHostError();
    if (state.lifecycle == MeetingTypeLifecycleState.deleted) throw const MeetingTypeDeletedError();
    yield MeetingTypeEditedEvent(
      meetingTypeId: command.meetingTypeId,
      meetingTitle: command.meetingTitle,
      durationMinutes: command.durationMinutes,
      meetingLocation: command.meetingLocation,
      scheduleId: command.scheduleId,
      meetingDescription: command.meetingDescription,
    );
  },
  evolve: (state, event) => switch (event) {
    MeetingTypeCreatedEvent() => EditMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.active,
      hostId: event.hostId,
    ),
    MeetingTypeDisabledEvent() => EditMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.disabled,
      hostId: state.hostId,
    ),
    MeetingTypeEnabledEvent() => EditMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.active,
      hostId: state.hostId,
    ),
    MeetingTypeDeletedEvent() => EditMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.deleted,
      hostId: state.hostId,
    ),
    _ => state,
  },
);
