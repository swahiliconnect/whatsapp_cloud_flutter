import 'package:logger/logger.dart' as log;

/// Log levels for controlling verbosity of logging output.
enum LogLevel {
  /// No logging
  none,

  /// Only error messages
  error,

  /// Warnings and errors
  warning,

  /// Informational messages, warnings, and errors
  info,

  /// Detailed debug information and all above levels
  debug,

  /// Very detailed diagnostics (for development)
  verbose,
}

/// Custom logger for the WhatsApp Cloud API client.
///
/// Provides customizable logging with different verbosity levels
/// and consistent formatting throughout the package.
class Logger {
  /// The current log level for filtering output
  final LogLevel level;

  /// Internal logger instance
  final log.Logger _logger;

  /// Creates a new logger with the specified log level.
  ///
  /// [level] determines which messages will be output.
  Logger({
    this.level = LogLevel.info,
  }) : _logger = log.Logger(
          printer: log.PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 8,
            lineLength: 120,
            colors: true,
            printEmojis: true,
            printTime: true,
          ),
          level: _mapLogLevel(level),
        );

  /// Maps internal log level to the logger package's levels
  static log.Level _mapLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.none:
        return log.Level.nothing;
      case LogLevel.error:
        return log.Level.error;
      case LogLevel.warning:
        return log.Level.warning;
      case LogLevel.info:
        return log.Level.info;
      case LogLevel.debug:
        return log.Level.debug;
      case LogLevel.verbose:
        return log.Level.verbose;
    }
  }

  /// Logs a verbose message.
  ///
  /// Use for highly detailed tracing information.
  void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    if (level == LogLevel.verbose) {
      _logger.v(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Logs a debug message.
  ///
  /// Use for debugging information useful during development.
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (level.index >= LogLevel.debug.index) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Logs an informational message.
  ///
  /// Use for general information about application flow.
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (level.index >= LogLevel.info.index) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Logs a warning message.
  ///
  /// Use for potentially problematic situations that don't prevent operation.
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (level.index >= LogLevel.warning.index) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Logs an error message.
  ///
  /// Use for errors that prevent normal operation.
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (level.index >= LogLevel.error.index) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Creates a new logger with the specified log level.
  Logger copyWith({
    LogLevel? level,
  }) {
    return Logger(
      level: level ?? this.level,
    );
  }
}