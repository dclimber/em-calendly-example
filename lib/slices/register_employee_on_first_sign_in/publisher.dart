import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'register_employee/aggregate.dart';
import 'register_employee/command.dart';
import 'register_employee/repository.dart';

/// Publishes `register_employee` commands by handling each one on the `employee` aggregate.
///
/// The command carries no sealed error: the decider accepts every command, so the publisher lets any exception
/// propagate, and the event then comes back later.
ActionPublisher<RegisterEmployeeCommand, NoMetadata, NoMetadata> createRegisterEmployeePublisher(
  EventStore eventStore,
) {
  Future<void> register(RegisterEmployeeCommand command) async {
    await handleCommand(() => buildRegisterEmployeeAggregate(RegisterEmployeeEventRepository(eventStore)), command);
  }

  return createActionPublisher(
    publish: (actions) async* {
      await for (final command in actions) {
        await register(command);
        yield command;
      }
    },
    publishWithMetadata: (actions) async* {
      await for (final (command, metadata) in actions) {
        await register(command);
        yield (command, metadata);
      }
    },
  );
}
