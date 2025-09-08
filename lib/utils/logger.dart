import 'package:logging/logging.dart';

/// Utility class for logging throughout the app
class AppLogger {
  static final Logger _logger = Logger('HTURentalsApp');

  static Logger get logger => _logger;

  /// Log an info message
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.info(message, error, stackTrace);
  }

  /// Log a warning message
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.warning(message, error, stackTrace);
  }

  /// Log an error message
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  /// Log a debug message
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.fine(message, error, stackTrace);
  }

  /// Log a fine message (more detailed debug)
  static void fine(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.finer(message, error, stackTrace);
  }

  /// Log a config message
  static void config(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.config(message, error, stackTrace);
  }

  /// Get a logger for a specific component
  static Logger getLogger(String name) {
    return Logger(name);
  }
}
