import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../auth/auth_interface.dart';
import '../config/api_config.dart';
import '../config/constants.dart';
import '../exceptions/api_exception.dart';
import '../exceptions/auth_exception.dart';
import '../utils/logger.dart';
import 'rate_limiter.dart';

/// Core API client for WhatsApp Cloud API communication.
///
/// Handles HTTP requests, authentication, error handling, and retries.
class ApiClient {
  /// Base URL for the WhatsApp Cloud API
  final String baseUrl;

  /// Authentication manager for token management
  final AuthManagerInterface authManager;

  /// Logger for API client events
  final Logger _logger;

  /// Connection timeout duration
  final Duration connectTimeout;

  /// Response timeout duration
  final Duration receiveTimeout;

  /// Retry policy for failed requests
  final RetryPolicy retryPolicy;

  /// Rate limiter for respecting API rate limits
  late final RateLimiter _rateLimiter;

  /// Dio HTTP client instance
  late final Dio _dio;

  /// Creates a new API client for WhatsApp Cloud API.
  ///
  /// [baseUrl] is the base URL for the WhatsApp Cloud API.
  /// [authManager] handles authentication tokens.
  /// [logger] is used for logging API client events.
  /// [connectTimeout] is the connection timeout duration.
  /// [receiveTimeout] is the response timeout duration.
  /// [retryPolicy] defines the retry behavior for failed requests.
  ApiClient({
    required this.baseUrl,
    required this.authManager,
    required Logger logger,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.retryPolicy = const RetryPolicy(),
  }) : _logger = logger {
    _rateLimiter = RateLimiter(
      maxRequests: Constants.rateLimit,
      interval: const Duration(minutes: 1),
      logger: _logger,
    );

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: Constants.defaultHeaders,
      ),
    );

    _configureInterceptors();
    _logger.debug('ApiClient initialized with baseUrl: $baseUrl');
  }

  /// Configures Dio interceptors for logging and error handling
  void _configureInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.debug('Request: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.debug(
            'Response: ${response.statusCode} ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.error(
            'Error: ${error.response?.statusCode} ${error.requestOptions.uri}',
            error,
          );
          return handler.next(error);
        },
      ),
    );
  }

  /// Performs a GET request to the specified endpoint.
  ///
  /// [endpoint] is the API endpoint path (without base URL).
  /// [queryParameters] are URL query parameters.
  /// [options] allows customizing the request behavior.
  /// Returns the parsed response body.
  /// Throws [ApiException] or [AuthException] on error.
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// Performs a POST request to the specified endpoint.
  ///
  /// [endpoint] is the API endpoint path (without base URL).
  /// [data] is the request body.
  /// [queryParameters] are URL query parameters.
  /// [options] allows customizing the request behavior.
  /// Returns the parsed response body.
  /// Throws [ApiException] or [AuthException] on error.
  Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// Performs a PUT request to the specified endpoint.
  ///
  /// [endpoint] is the API endpoint path (without base URL).
  /// [data] is the request body.
  /// [queryParameters] are URL query parameters.
  /// [options] allows customizing the request behavior.
  /// Returns the parsed response body.
  /// Throws [ApiException] or [AuthException] on error.
  Future<dynamic> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// Performs a DELETE request to the specified endpoint.
  ///
  /// [endpoint] is the API endpoint path (without base URL).
  /// [data] is the request body.
  /// [queryParameters] are URL query parameters.
  /// [options] allows customizing the request behavior.
  /// Returns the parsed response body.
  /// Throws [ApiException] or [AuthException] on error.
  Future<dynamic> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// Executes a request with retry logic and error handling.
  ///
  /// [requestFn] is a function that performs the actual HTTP request.
  /// Returns the parsed response body.
  /// Throws [ApiException] or [AuthException] on error.
  Future<dynamic> _executeRequest(
    Future<Response<dynamic>> Function() requestFn,
  ) async {
    int retryCount = 0;
    dynamic lastError;

    while (retryCount <= retryPolicy.maxRetries) {
      try {
        // Wait for rate limiter before proceeding
        await _rateLimiter.acquire();

        // Add auth headers directly to the request options
        _dio.options.headers.addAll(authManager.getAuthHeaders());

        final response = await requestFn();
        return _processResponse(response);
      } on DioException catch (e) {
        lastError = e;
        
        final shouldRetry = _shouldRetry(e, retryCount);
        if (!shouldRetry) {
          throw _handleDioError(e);
        }

        // Calculate backoff time
        final backoff = _calculateBackoff(retryCount);
        _logger.warning(
          'Request failed, retrying in ${backoff.inSeconds} seconds (${retryCount + 1}/${retryPolicy.maxRetries})',
        );
        
        await Future.delayed(backoff);
        retryCount++;
      } catch (e) {
        _logger.error('Unexpected error during API request', e);
        lastError = e;
        break;
      }
    }

    // If we've exhausted retries, throw the last error
    if (lastError is DioException) {
      throw _handleDioError(lastError);
    } else {
      throw ApiException(
        statusCode: 0,
        message: 'Unexpected error: ${lastError.toString()}',
        originalException: lastError,
      );
    }
  }

  /// Processes the API response.
  ///
  /// [response] is the HTTP response from the API.
  /// Returns the parsed response body.
  /// Throws [ApiException] for invalid responses.
  dynamic _processResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 200 && statusCode < 300) {
      return response.data;
    } else {
      throw _handleErrorResponse(statusCode, response.data);
    }
  }

  /// Determines if a failed request should be retried.
  ///
  /// [error] is the error that caused the request to fail.
  /// [retryCount] is the current retry attempt number.
  /// Returns true if the request should be retried.
  bool _shouldRetry(DioException error, int retryCount) {
    // Don't retry if we've exhausted retry attempts
    if (retryCount >= retryPolicy.maxRetries) {
      return false;
    }

    // Retry on timeout errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Retry on connection errors
    if (error.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on server errors (5xx)
    final statusCode = error.response?.statusCode ?? 0;
    if (statusCode >= 500 && statusCode < 600) {
      return true;
    }

    // Retry on rate limit errors
    if (statusCode == 429) {
      return true;
    }

    // Don't retry other errors
    return false;
  }

  /// Calculates the backoff time for retries.
  ///
  /// [retryCount] is the current retry attempt number.
  /// Returns a duration to wait before retrying.
  Duration _calculateBackoff(int retryCount) {
    // Exponential backoff with jitter
    final backoffMs = retryPolicy.initialBackoff.inMilliseconds *
        (1 << retryCount); // 2^retryCount
    final jitter = (backoffMs * 0.2 * (DateTime.now().millisecond % 10) / 10)
        .floor(); // Add up to 20% jitter
    final totalBackoffMs = backoffMs + jitter;

    // Cap at max backoff
    final cappedBackoffMs = totalBackoffMs < retryPolicy.maxBackoff.inMilliseconds
        ? totalBackoffMs
        : retryPolicy.maxBackoff.inMilliseconds;

    return Duration(milliseconds: cappedBackoffMs);
  }

  /// Handles Dio error responses.
  ///
  /// [error] is the Dio error that occurred.
  /// Returns an appropriate exception based on the error type.
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException.connectionTimeout(error);
      case DioExceptionType.receiveTimeout:
        return ApiException.receiveTimeout(error);
      case DioExceptionType.connectionError:
        return ApiException.networkError(error);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final responseData = error.response?.data;
        return _handleErrorResponse(statusCode, responseData, error);
      case DioExceptionType.cancel:
        return ApiException(
          statusCode: 0,
          message: 'Request was cancelled',
          code: 'request_cancelled',
          originalException: error,
        );
      case DioExceptionType.unknown:
      default:
        return ApiException(
          statusCode: 0,
          message: 'Unknown error occurred',
          code: 'unknown_error',
          originalException: error,
        );
    }
  }

  /// Handles error responses based on status code.
  ///
  /// [statusCode] is the HTTP status code from the response.
  /// [responseData] is the response body.
  /// [originalException] is the original exception if available.
  /// Returns an appropriate exception based on the status code.
  Exception _handleErrorResponse(
    int statusCode,
    dynamic responseData, [
    dynamic originalException,
  ]) {
    // Extract error details if available
    String? errorCode;
    String errorMessage = 'Unknown error';

    if (responseData is Map<String, dynamic>) {
      errorCode = responseData['error']?['code']?.toString();
      errorMessage = responseData['error']?['message']?.toString() ??
          responseData['message']?.toString() ??
          errorMessage;
    } else if (responseData is String) {
      try {
        final jsonData = json.decode(responseData);
        if (jsonData is Map<String, dynamic>) {
          errorCode = jsonData['error']?['code']?.toString();
          errorMessage = jsonData['error']?['message']?.toString() ??
              jsonData['message']?.toString() ??
              errorMessage;
        }
      } catch (_) {
        // Not valid JSON, use response as is
        errorMessage = responseData;
      }
    }

    // Handle different status code ranges
    if (statusCode == 401 || statusCode == 403) {
      return AuthException(
        code: errorCode ?? 'authentication_error',
        message: errorMessage,
        originalException: originalException,
      );
    } else if (statusCode == 429) {
      // Extract retry-after header if available
      int retryAfterSeconds = 60; // Default to 1 minute
      
      if (originalException is DioException &&
          originalException.response?.headers.map.containsKey('retry-after') == true) {
        try {
          retryAfterSeconds = int.parse(
            originalException.response!.headers.value('retry-after') ?? '60',
          );
        } catch (_) {
          // Use default if parse fails
        }
      }
      
      return ApiException.rateLimited(
        retryAfterSeconds,
        responseData,
        originalException,
      );
    } else if (statusCode >= 400 && statusCode < 500) {
      return ApiException.clientError(
        statusCode,
        responseData,
        originalException,
      );
    } else if (statusCode >= 500) {
      return ApiException.serverError(
        statusCode,
        responseData,
        originalException,
      );
    } else {
      return ApiException(
        statusCode: statusCode,
        message: errorMessage,
        code: errorCode,
        responseBody: responseData,
        originalException: originalException,
      );
    }
  }

  /// Gets the underlying Dio instance for advanced usage.
  @visibleForTesting
  Dio get dio => _dio;
}