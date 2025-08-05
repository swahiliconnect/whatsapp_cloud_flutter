/// Base exception for all API-related errors.
class ApiException implements Exception {
  /// HTTP status code of the error response
  final int statusCode;

  /// Error code returned by the API, if available
  final String? code;

  /// Human-readable error message
  final String message;

  /// Original error response body
  final dynamic responseBody;

  /// Original exception that caused this API exception
  final dynamic originalException;

  /// Creates a new API exception.
  ///
  /// [statusCode] is the HTTP status code from the API response.
  /// [message] is a human-readable error message.
  /// [code] is an optional error code returned by the API.
  /// [responseBody] is the original response body from the API.
  /// [originalException] is the underlying exception if available.
  ApiException({
    required this.statusCode,
    required this.message,
    this.code,
    this.responseBody,
    this.originalException,
  });

  /// Creates an exception for connection timeout.
  factory ApiException.connectionTimeout([dynamic originalException]) {
    return ApiException(
      statusCode: 0,
      message: 'Connection timeout',
      code: 'connection_timeout',
      originalException: originalException,
    );
  }

  /// Creates an exception for receive timeout.
  factory ApiException.receiveTimeout([dynamic originalException]) {
    return ApiException(
      statusCode: 0,
      message: 'Receive timeout',
      code: 'receive_timeout',
      originalException: originalException,
    );
  }

  /// Creates an exception for network connectivity issues.
  factory ApiException.networkError([dynamic originalException]) {
    return ApiException(
      statusCode: 0,
      message: 'Network error',
      code: 'network_error',
      originalException: originalException,
    );
  }

  /// Creates an exception for server errors (5xx status codes).
  factory ApiException.serverError(
    int statusCode,
    dynamic responseBody, [
    dynamic originalException,
  ]) {
    return ApiException(
      statusCode: statusCode,
      message: 'Server error',
      code: 'server_error',
      responseBody: responseBody,
      originalException: originalException,
    );
  }

  /// Creates an exception for client errors (4xx status codes).
  factory ApiException.clientError(
    int statusCode,
    dynamic responseBody, [
    dynamic originalException,
  ]) {
    return ApiException(
      statusCode: statusCode,
      message: 'Client error',
      code: 'client_error',
      responseBody: responseBody,
      originalException: originalException,
    );
  }

  /// Creates an exception for unexpected responses.
  factory ApiException.unexpectedResponse(
    dynamic responseBody, [
    dynamic originalException,
  ]) {
    return ApiException(
      statusCode: 0,
      message: 'Unexpected response',
      code: 'unexpected_response',
      responseBody: responseBody,
      originalException: originalException,
    );
  }

  /// Creates an exception for rate limiting (429 status code).
  factory ApiException.rateLimited(
    int retryAfterSeconds,
    dynamic responseBody, [
    dynamic originalException,
  ]) {
    return RateLimitException(
      retryAfterSeconds: retryAfterSeconds,
      responseBody: responseBody,
      originalException: originalException,
    );
  }

  @override
  String toString() {
    final codeStr = code != null ? '[$code]' : '';
    return 'ApiException: $codeStr HTTP $statusCode - $message';
  }
}

/// Specialized exception for rate limiting errors.
class RateLimitException extends ApiException {
  /// Time in seconds to wait before retrying
  final int retryAfterSeconds;

  /// Creates a new rate limit exception.
  ///
  /// [retryAfterSeconds] is the time to wait before retrying.
  /// [responseBody] is the original response body from the API.
  /// [originalException] is the underlying exception if available.
  RateLimitException({
    required this.retryAfterSeconds,
    dynamic responseBody,
    dynamic originalException,
  }) : super(
          statusCode: 429,
          message: 'Rate limit exceeded',
          code: 'rate_limited',
          responseBody: responseBody,
          originalException: originalException,
        );

  /// Duration to wait before retrying
  Duration get retryAfter => Duration(seconds: retryAfterSeconds);

  @override
  String toString() {
    return 'RateLimitException: Rate limit exceeded, retry after $retryAfterSeconds seconds';
  }
}