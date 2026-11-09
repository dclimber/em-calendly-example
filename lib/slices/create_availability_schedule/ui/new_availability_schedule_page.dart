import 'package:jaspr/server.dart';

import '../../../ui/kit.dart';
import '../../../ui/paths.dart';

/// The screen `new_availability_schedule`: a schedule name and a time zone, posted to the schedules route.
final class NewAvailabilitySchedulePage extends StatelessComponent {
  const NewAvailabilitySchedulePage({super.key});

  @override
  Component build(BuildContext context) {
    return Panel(
      title: 'New availability schedule',
      children: [
        PostForm(
          action: schedulesRoute,
          submitLabel: 'Create schedule',
          children: [
            Field(
              label: 'Schedule name',
              input: textInput('schedule_name', placeholder: 'Working hours', required: true),
            ),
            Field(
              label: 'Time zone',
              hint: 'IANA time zone name, for example Europe/Berlin.',
              input: textInput('time_zone', value: 'Europe/Berlin', required: true),
            ),
          ],
        ),
      ],
    );
  }
}
