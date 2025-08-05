import '../utils/logger.dart';

/// Analytics and metrics collection for WhatsApp Cloud API usage.
class WhatsAppAnalytics {
  final Logger _logger;
  final Map<String, int> _messageTypeCounts = {};
  final Map<String, int> _errorCounts = {};
  final List<Duration> _responseTimes = [];
  DateTime? _lastResetTime;

  /// Creates a new analytics instance.
  WhatsAppAnalytics({
    required Logger logger,
  }) : _logger = logger {
    _lastResetTime = DateTime.now();
  }

  /// Records a message sent event.
  void recordMessageSent(String messageType, Duration responseTime) {
    _messageTypeCounts[messageType] = (_messageTypeCounts[messageType] ?? 0) + 1;
    _responseTimes.add(responseTime);
    
    _logger.debug('Message sent: $messageType, Response time: ${responseTime.inMilliseconds}ms');
  }

  /// Records an error event.
  void recordError(String errorType, String? errorCode) {
    final key = errorCode != null ? '$errorType:$errorCode' : errorType;
    _errorCounts[key] = (_errorCounts[key] ?? 0) + 1;
    
    _logger.debug('Error recorded: $key');
  }

  /// Gets message type statistics.
  Map<String, int> get messageTypeStats => Map.unmodifiable(_messageTypeCounts);

  /// Gets error statistics.
  Map<String, int> get errorStats => Map.unmodifiable(_errorCounts);

  /// Gets average response time in milliseconds.
  double? get averageResponseTime {
    if (_responseTimes.isEmpty) return null;
    
    final totalMs = _responseTimes
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a + b);
    
    return totalMs / _responseTimes.length;
  }

  /// Gets success rate as a percentage.
  double get successRate {
    final totalMessages = _messageTypeCounts.values
        .fold<int>(0, (sum, count) => sum + count);
    
    final totalErrors = _errorCounts.values
        .fold<int>(0, (sum, count) => sum + count);
    
    final totalRequests = totalMessages + totalErrors;
    
    if (totalRequests == 0) return 100.0;
    
    return (totalMessages / totalRequests) * 100;
  }

  /// Resets all statistics.
  void reset() {
    _messageTypeCounts.clear();
    _errorCounts.clear();
    _responseTimes.clear();
    _lastResetTime = DateTime.now();
    
    _logger.info('Analytics data reset');
  }

  /// Gets a summary report of all statistics.
  Map<String, dynamic> getSummaryReport() {
    return {
      'period': {
        'start': _lastResetTime?.toIso8601String(),
        'end': DateTime.now().toIso8601String(),
      },
      'messages': {
        'by_type': messageTypeStats,
        'total': _messageTypeCounts.values.fold<int>(0, (a, b) => a + b),
      },
      'errors': {
        'by_type': errorStats,
        'total': _errorCounts.values.fold<int>(0, (a, b) => a + b),
      },
      'performance': {
        'average_response_time_ms': averageResponseTime,
        'success_rate_percent': successRate,
      },
    };
  }
}

/// Rate limiting configuration and enforcement.
class RateLimitConfig {
  /// Maximum number of requests per minute
  final int requestsPerMinute;

  /// Maximum number of requests per hour
  final int requestsPerHour;

  /// Maximum number of requests per day
  final int requestsPerDay;

  /// Whether to enforce rate limits
  final bool enabled;

  /// Creates a new rate limit configuration.
  const RateLimitConfig({
    this.requestsPerMinute = 1000,
    this.requestsPerHour = 100000,
    this.requestsPerDay = 1000000,
    this.enabled = true,
  });

  /// Default rate limits based on WhatsApp Cloud API free tier.
  static const RateLimitConfig defaultLimits = RateLimitConfig(
    requestsPerMinute: 80,
    requestsPerHour: 1000,
    requestsPerDay: 10000,
  );

  /// Business tier rate limits.
  static const RateLimitConfig businessLimits = RateLimitConfig(
    requestsPerMinute: 1000,
    requestsPerHour: 100000,
    requestsPerDay: 1000000,
  );
}
