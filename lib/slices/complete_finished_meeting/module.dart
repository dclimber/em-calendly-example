import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/jobs/job_scheduler.dart';
import '../../platform/view_store/materialized_view.dart';
import 'complete_meeting/service.dart';
import 'meetings_to_complete/repository.dart';
import 'meetings_to_complete/view.dart';
import 'worker.dart';

/// The automation `complete_finished_meeting`: a worker that completes each confirmed meeting once its end time has
/// passed. Its to-do list is `meetings_to_complete`.
final class CompleteFinishedMeetingSlice implements VerticalSlice {
  const CompleteFinishedMeetingSlice();

  @override
  String get name => 'complete_finished_meeting';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final repository = MeetingsToCompleteRepository(services.viewStore);
    final service = CompleteMeetingService(eventStore: services.eventStore);
    registrar
      ..subscribe(
        materializedViewSubscription(
          view: meetingsToCompleteView,
          repository: repository,
          eventTypes: const {
            MeetingSlotReservedEvent,
            MeetingConfirmedEvent,
            MeetingRescheduleRequestedEvent,
            MeetingRescheduledEvent,

            /// Needed to drop a failed request's end. The model's `from` list omits it, so the subscription must name it.
            /// Without it a failed reschedule would keep the end it requested.
            MeetingRescheduleFailedEvent,
            MeetingMovedInCalendarEvent,
            MeetingCanceledEvent,
            MeetingCompletedEvent,
          },
        ),
      )
      ..schedule(
        ScheduledJob(
          name: 'complete_finished_meeting',
          interval: const Duration(minutes: 1),
          run: () => completeFinishedMeetings(repository: repository, service: service, clock: services.clock),
        ),
      );
  }
}
