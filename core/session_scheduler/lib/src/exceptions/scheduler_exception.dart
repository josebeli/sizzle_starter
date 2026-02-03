/// {@template scheduler_exception}
/// Exception thrown by the session scheduler.
/// {@endtemplate}
final class SchedulerException implements Exception {
  /// {@macro scheduler_exception}
  const SchedulerException(this.message);

  final String message;

  @override
  String toString() => 'SchedulerException: $message';
}