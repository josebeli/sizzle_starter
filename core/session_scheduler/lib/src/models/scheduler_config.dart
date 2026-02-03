import 'package:meta/meta.dart';

/// {@template scheduler_config}
/// Configuration for the session scheduler.
/// {@endtemplate}
@immutable
class SchedulerConfig {
  /// {@macro scheduler_config}
  const SchedulerConfig({
    this.delayMs = 0,
    this.maxRetries = 3,
    this.autoFinalize = true,
  });

  /// Delay between turns in milliseconds.
  final int delayMs;

  /// Maximum retry attempts per turn.
  final int maxRetries;

  /// Whether to auto-finalize when no active items remain.
  final bool autoFinalize;

  /// Creates a copy with modified fields.
  SchedulerConfig copyWith({
    int? delayMs,
    int? maxRetries,
    bool? autoFinalize,
  }) =>
      SchedulerConfig(
        delayMs: delayMs ?? this.delayMs,
        maxRetries: maxRetries ?? this.maxRetries,
        autoFinalize: autoFinalize ?? this.autoFinalize,
      );
}