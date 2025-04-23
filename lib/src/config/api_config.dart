import 'package:meta/meta.dart';

import 'constants.dart';
import 'environment.dart';
import '../utils/logger.dart';

/// Configuration for retry behavior when API requests fail.
@immutable
class RetryPolicy {
  /// Maximum number of retry attempts
  final int maxRetries;

  /// Initial wait time before the first retry
  final Duration initialBackoff;

  /// Maximum wait time between retries
  final Duration maxBackoff;

  /// Creates a new retry policy with the specified settings.
  ///
  /// [maxRetries] is the maximum number of retry attempts (default: 3).
  /// [initialBackoff] is the initial backoff duration (default: 1 second).
  /// [maxBackoff] is the maximum backoff duration (default: 10 seconds).
  const RetryPolicy({
    this.maxRetries = 3,
    this.initialBackoff = const Duration(seconds: 1),
    this.maxBackoff = const Duration(seconds: 10),
  });
}

/// Configuration for the WhatsApp Cloud API client.
@immutable
class WhatsAppApiConfig {
  /// Base URL for the WhatsApp Cloud API
  final String baseUrl;

  /// Connection timeout for API requests
  final Duration connectTimeout;

  /// Response timeout for API requests
  final Duration receiveTimeout;

  /// Logger level for debugging and monitoring
  final LogLevel logLevel;

  /// Retry policy for failed requests
  final RetryPolicy retryPolicy;

  /// Current API environment (production/sandbox)
  final Environment environment;

  /// Creates a new API configuration with the specified settings.
  ///
  /// [baseUrl] is the base URL for the WhatsApp Cloud API.
  /// [connectTimeout] is the connection timeout for requests.
  /// [receiveTimeout] is the response timeout for requests.
  /// [logLevel] controls the verbosity of logging.
  /// [retryPolicy] defines the retry behavior for failed requests.
  /// [environment] specifies which API environment to use.
  const WhatsAppApiConfig({
    this.baseUrl = Constants.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.logLevel = LogLevel.info,
    this.retryPolicy = const RetryPolicy(),
    this.environment = Environment.production,
  });

  /// Creates a copy of this configuration with the specified fields replaced.
  WhatsAppApiConfig copyWith({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    LogLevel? logLevel,
    RetryPolicy? retryPolicy,
    Environment? environment,
  }) {
    return WhatsAppApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      logLevel: logLevel ?? this.logLevel,
      retryPolicy: retryPolicy ?? this.retryPolicy,
      environment: environment ?? this.environment,
    );
  }
}