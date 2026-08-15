import 'dart:developer' as dev;

/// Lightweight logger.
///
/// All output goes through `dart:developer` `log` with the name `Logger`,
/// so it shows up in DevTools and is easy to filter.
abstract final class Logger {
  static const _name = 'Logger';

  /// Log an event with an optional context map.
  static void d(String message, [String? name, Map<String, Object?>? context]) {
    dev.log(_format(message, context), name: name ?? _name);
  }

  /// Log a warning.
  static void w(String message, [String? name, Map<String, Object?>? context]) {
    dev.log(_format(message, context), name: name ?? _name, level: 900);
  }

  /// Log an error.
  static void e(
    String message, [
    String? name,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    dev.log(
      message,
      name: name ?? _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _format(String message, Map<String, Object?>? context) {
    if (context == null || context.isEmpty) return message;
    final params = context.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    return '$message ($params)';
  }
}
