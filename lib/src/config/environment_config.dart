/// Environment configuration for different deployment stages.
class EnvironmentConfig {
  /// WhatsApp Cloud API base URL
  final String baseUrl;
  
  /// API version
  final String apiVersion;
  
  /// Whether to enable debug logging
  final bool enableDebugLogging;
  
  /// Rate limiting configuration
  final Map<String, int> rateLimits;
  
  /// Request timeout in milliseconds
  final int timeoutMs;
  
  /// Maximum retry attempts
  final int maxRetries;
  
  const EnvironmentConfig({
    required this.baseUrl,
    required this.apiVersion,
    required this.enableDebugLogging,
    required this.rateLimits,
    required this.timeoutMs,
    required this.maxRetries,
  });
  
  /// Development environment configuration
  static const EnvironmentConfig development = EnvironmentConfig(
    baseUrl: 'https://graph.facebook.com',
    apiVersion: 'v21.0',
    enableDebugLogging: true,
    rateLimits: {
      'requests_per_minute': 80,
      'requests_per_hour': 1000,
      'requests_per_day': 10000,
    },
    timeoutMs: 30000,
    maxRetries: 3,
  );
  
  /// Production environment configuration
  static const EnvironmentConfig production = EnvironmentConfig(
    baseUrl: 'https://graph.facebook.com',
    apiVersion: 'v21.0',
    enableDebugLogging: false,
    rateLimits: {
      'requests_per_minute': 1000,
      'requests_per_hour': 100000,
      'requests_per_day': 1000000,
    },
    timeoutMs: 15000,
    maxRetries: 5,
  );
  
  /// Testing environment configuration
  static const EnvironmentConfig testing = EnvironmentConfig(
    baseUrl: 'https://graph.facebook.com',
    apiVersion: 'v21.0',
    enableDebugLogging: true,
    rateLimits: {
      'requests_per_minute': 10,
      'requests_per_hour': 100,
      'requests_per_day': 1000,
    },
    timeoutMs: 5000,
    maxRetries: 1,
  );
}
