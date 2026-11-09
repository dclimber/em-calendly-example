import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'state.dart';

/// The pure view of `my_meeting_types`, one document per meeting type. `meeting_type_created` creates the document with
/// its booking link. Edits change the details and keep the link and the active flag. Disabling and enabling set the
/// active flag. Deleting removes the document, so the meeting type leaves the list. Events that arrive before their
/// meeting type was created change nothing.
final myMeetingTypesView = View<MyMeetingType?, HostSetupEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingTypeCreatedEvent(
      :final meetingTypeId,
      :final hostId,
      :final meetingTitle,
      :final durationMinutes,
      :final meetingLocation,
      :final bookingUrl,
    ) =>
      MyMeetingType(
        meetingTypeId: meetingTypeId,
        hostId: hostId,
        meetingTitle: meetingTitle,
        durationMinutes: durationMinutes,
        meetingLocation: meetingLocation,
        bookingUrl: bookingUrl,
        active: true,
      ),
    MeetingTypeEditedEvent(:final meetingTitle, :final durationMinutes, :final meetingLocation) => state?.withDetails(
      meetingTitle: meetingTitle,
      durationMinutes: durationMinutes,
      meetingLocation: meetingLocation,
    ),
    MeetingTypeDisabledEvent() => state?.withActive(false),
    MeetingTypeEnabledEvent() => state?.withActive(true),
    MeetingTypeDeletedEvent() => null,
    _ => state,
  },
);
