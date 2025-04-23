import 'dart:async';
import 'dart:collection';

import '../utils/logger.dart';

/// Rate limiter for API requests to prevent exceeding API rate limits.
class RateLimiter {
  /// Maximum number of requests allowed in the interval
  final int maxRequests;

  /// Time interval for rate limiting
  final Duration interval;

  /// Logger for rate limiter events
  final Logger _logger;

  /// Queue of timestamps for recent requests
  final Queue<DateTime> _requestTimestamps = Queue<DateTime>();

  /// Completer for the current rate limit wait
  Completer<void>? _waitCompleter;

  /// Timer for clearing expired timestamps
  Timer? _cleanupTimer;

  /// Creates a new rate limiter.
  ///
  /// [maxRequests] is the maximum number of requests allowed in the interval.
  /// [interval] is the time interval for rate limiting.
  /// [logger] is used for logging rate limiter events.
  RateLimiter({
    required this.maxRequests,
    required this.interval,
    required Logger logger,
  }) : _logger = logger {
    // Start the cleanup timer
    _cleanupTimer = Timer.periodic(
      Duration(seconds: 10),
      (_) => _removeExpiredTimestamps(),
    );
    
    _logger.debug(
      'RateLimiter initialized: $maxRequests requests per ${interval.inSeconds} seconds',
    );
  }

  /// Acquires permission to make a request, waiting if necessary.
  ///
  /// Returns a future that completes when the request can proceed.
  Future<void> acquire() async {
    final now = DateTime.now();
    
    // Remove expired timestamps
    _removeExpiredTimestamps();

    // Check if we're at the rate limit
    if (_requestTimestamps.length >= maxRequests) {
      // Calculate time to wait before next request
      final oldestTimestamp = _requestTimestamps.first;
      final timeToWait = interval - now.difference(oldestTimestamp);
      
      if (timeToWait.isNegative) {
        // We can proceed immediately
        _addRequest(now);
        return;
      }
      
      _logger.warning(
        'Rate limit reached, waiting ${timeToWait.inMilliseconds}ms before next request',
      );
      
      // Wait until we can make another request
      _waitCompleter = Completer<void>();
      
      // Schedule the completer to complete after the wait time
      Timer(timeToWait, () {
        final completer = _waitCompleter;
        if (completer != null && !completer.isCompleted) {
          _waitCompleter = null;
          completer.complete();
        }
      });
      
      await _waitCompleter!.future;
    }
    
    // Add the current request
    _addRequest(now);
  }

  /// Adds a new request timestamp to the queue.
  void _addRequest(DateTime timestamp) {
    _requestTimestamps.add(timestamp);
    _logger.debug(
      'Request added to rate limiter (${_requestTimestamps.length}/$maxRequests)',
    );
  }

  /// Removes expired timestamps from the queue.
  void _removeExpiredTimestamps() {
    final now = DateTime.now();
    final cutoff = now.subtract(interval);
    
    while (_requestTimestamps.isNotEmpty &&
        _requestTimestamps.first.isBefore(cutoff)) {
      _requestTimestamps.removeFirst();
    }
  }

  /// Disposes the rate limiter.
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    
    final completer = _waitCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    
    _requestTimestamps.clear();
    _logger.debug('RateLimiter disposed');
  }
}