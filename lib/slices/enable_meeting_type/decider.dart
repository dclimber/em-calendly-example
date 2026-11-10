import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting_type` aggregate for `enable_meeting_type`.
///
/// Transition `enable` (before `disabled`, after `active`) emits `meeting_type_enabled`. Invalid transition
/// `enable_deleted` refuses a deleted meeting type; that check runs first, so a deleted meeting type is refused with its
/// model text even when its creation is not in the history. The model states no rule for a meeting type that is already
/// active or does not exist, so the decider adds no lifecycle check for those states (see the gap report). It refuses a
/// caller who is not the host of the meeting type, the same check as `disable_meeting_type`.
final enableMeetingTypeDecider = Decider<EnableMeetingTypeCommand, EnableMeetingTypeState, HostSetupEvent>(
  initialState: const EnableMeetingTypeState(),
  decide: (command, state) async* {
    if (state.lifecycle == MeetingTypeLifecycleState.deleted) throw const MeetingTypeDeletedCannotBeEnabledError();
    if (state.hostId != command.hostId) throw const NotMeetingTypeHostError();
    yield MeetingTypeEnabledEvent(meetingTypeId: command.meetingTypeId);
  },
  evolve: (state, event) => switch (event) {
    MeetingTypeCreatedEvent() => EnableMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.active,
      hostId: event.hostId,
    ),
    MeetingTypeDisabledEvent() => EnableMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.disabled,
      hostId: state.hostId,
    ),
    MeetingTypeEnabledEvent() => EnableMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.active,
      hostId: state.hostId,
    ),
    MeetingTypeDeletedEvent() => EnableMeetingTypeState(
      lifecycle: MeetingTypeLifecycleState.deleted,
      hostId: state.hostId,
    ),
    _ => state,
  },
);
