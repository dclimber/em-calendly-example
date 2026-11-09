import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting_type` aggregate for `disable_meeting_type`.
///
/// Transition `disable` (before `active`, after `disabled`) emits `meeting_type_disabled`. The model states no rule for
/// a meeting type that is already disabled or deleted, so the decider adds no check for those states (see the gap
/// report). It refuses a caller who is not the host of the meeting type, the same check as `edit_meeting_type`.
final disableMeetingTypeDecider = Decider<DisableMeetingTypeCommand, DisableMeetingTypeState, HostSetupEvent>(
  initialState: const DisableMeetingTypeState(),
  decide: (command, state) async* {
    if (state.hostId != command.hostId) throw const NotMeetingTypeHostError();
    yield MeetingTypeDisabledEvent(meetingTypeId: command.meetingTypeId);
  },
  evolve: (state, event) => switch (event) {
    MeetingTypeCreatedEvent() => DisableMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.active,
      hostId: event.hostId,
    ),
    MeetingTypeDisabledEvent() => DisableMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.disabled,
      hostId: state.hostId,
    ),
    MeetingTypeEnabledEvent() => DisableMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.active,
      hostId: state.hostId,
    ),
    MeetingTypeDeletedEvent() => DisableMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.deleted,
      hostId: state.hostId,
    ),
    _ => state,
  },
);
