import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/meetings/api.dart';
import '../../../ui/kit.dart';

/// The available slots as links. Each link goes to the page that confirms the slot, built by [hrefFor].
final class SlotList extends StatelessComponent {
  const SlotList({required this.slots, required this.hrefFor, super.key});

  final List<AvailableSlot> slots;
  final String Function(AvailableSlot slot) hrefFor;

  @override
  Component build(BuildContext context) {
    return ul(classes: 'slots', [
      for (final slot in slots)
        li([
          a(href: hrefFor(slot), [
            LocalTime(iso: slot.startAt.toUtc().toIso8601String()),
            Component.text(' to '),
            LocalTime(iso: slot.endAt.toUtc().toIso8601String(), timeOnly: true),
          ]),
        ]),
    ]);
  }
}
