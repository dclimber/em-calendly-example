/// The errors of `start_calendar_connection`. Each message is the text of the model.
sealed class StartCalendarConnectionError implements Exception {
  const StartCalendarConnectionError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The `start_when_already_connected` invalid transition.
final class StartWhenAlreadyConnectedError extends StartCalendarConnectionError {
  const StartWhenAlreadyConnectedError() : super('This calendar is already connected.');
}
