import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting_type` aggregate for `delete_meeting_type`.
///
/// Transition `delete` (before `active` or `disabled`, after `deleted`) emits `meeting_type_deleted`. Upcoming meetings
/// of the type are not read or changed: they remain (hotspot `delete_with_future_meetings`). The model states no rule for
/// a meeting type that is already deleted or does not exist, so the decider adds no lifecycle check for those states (see
/// the gap report). It refuses a caller who is not the host of the meeting type, the same check as the siblings.
final deleteMeetingTypeDecider = Decider<DeleteMeetingTypeCommand, DeleteMeetingTypeState, HostSetupEvent>(
  initialState: const DeleteMeetingTypeState(),
  decide: (command, state) async* {
    if (state.hostId != command.hostId) throw const NotMeetingTypeHostError();
    yield MeetingTypeDeletedEvent(meetingTypeId: command.meetingTypeId);
  },
  evolve: (state, event) => switch (event) {
    MeetingTypeCreatedEvent() => DeleteMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.active,
      hostId: event.hostId,
    ),
    MeetingTypeDisabledEvent() => DeleteMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.disabled,
      hostId: state.hostId,
    ),
    MeetingTypeEnabledEvent() => DeleteMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.active,
      hostId: state.hostId,
    ),
    MeetingTypeDeletedEvent() => DeleteMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.deleted,
      hostId: state.hostId,
    ),
    _ => state,
  },
);
