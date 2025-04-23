/// Exception thrown when authentication-related errors occur.
class AuthException implements Exception {
  /// Error code for the authentication error
  final String code;

  /// Human-readable error message
  final String message;

  /// Original exception that caused this authentication exception
  final dynamic originalException;

  /// Creates a new authentication exception.
  ///
  /// [code] is a machine-readable error code.
  /// [message] is a human-readable error message.
  /// [originalException] is the underlying exception if available.
  AuthException({
    required this.code,
    required this.message,
    this.originalException,
  });

  /// Creates an authentication exception for missing token.
  factory AuthException.missingToken() {
    return AuthException(
      code: 'missing_token',
      message: 'Authentication token is missing or empty',
    );
  }

  /// Creates an authentication exception for invalid token.
  factory AuthException.invalidToken([dynamic originalException]) {
    return AuthException(
      code: 'invalid_token',
      message: 'Authentication token is invalid or expired',
      originalException: originalException,
    );
  }

  /// Creates an authentication exception for unauthorized access.
  factory AuthException.unauthorized([dynamic originalException]) {
    return AuthException(
      code: 'unauthorized',
      message: 'Unauthorized access to the requested resource',
      originalException: originalException,
    );
  }

  /// Creates an authentication exception for token storage failure.
  factory AuthException.tokenStorageFailure([dynamic originalException]) {
    return AuthException(
      code: 'token_storage_failure',
      message: 'Failed to store or retrieve authentication token',
      originalException: originalException,
    );
  }

  @override
  String toString() {
    return 'AuthException: [$code] $message';
  }
}