import 'package:meta/meta.dart';

import '../exceptions/auth_exception.dart';
import '../utils/logger.dart';
import 'auth_interface.dart';
import 'token_storage.dart';

/// Manages authentication for the WhatsApp Cloud API.
///
/// Handles token storage, retrieval, and validation to ensure
/// the client maintains proper authentication.
class AuthManager implements AuthManagerInterface {
  /// Access token for WhatsApp Cloud API
  final String accessToken;

  /// Optional token storage for persistent token storage
  final TokenStorage? tokenStorage;

  /// Logger for authentication-related events
  final Logger _logger;

  /// Creates a new authentication manager.
  ///
  /// [accessToken] is the WhatsApp Cloud API access token.
  /// [tokenStorage] is an optional mechanism for persistent token storage.
  /// [logger] is used for logging authentication events.
  AuthManager({
    required this.accessToken,
    this.tokenStorage,
    required Logger logger,
  }) : _logger = logger {
    _validateToken();
    _logger.debug('AuthManager initialized');
  }

  /// Validates that the provided token is not empty
  void _validateToken() {
    if (accessToken.isEmpty) {
      _logger.error('Authentication token is missing or empty');
      throw AuthException.missingToken();
    }
  }

  /// Gets the current authentication token.
  ///
  /// Returns the access token for API requests.
  /// Throws [AuthException] if token is invalid or missing.
  @override
  String getToken() {
    try {
      _validateToken();
      return accessToken;
    } catch (e) {
      _logger.error('Failed to get authentication token', e);
      rethrow;
    }
  }

  /// Gets the authentication headers for API requests.
  ///
  /// Returns a map containing the Authorization header with the bearer token.
  /// Throws [AuthException] if token is invalid or missing.
  @override
  Map<String, String> getAuthHeaders() {
    final token = getToken();
    _logger.debug('Generated auth headers');
    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Checks if the current token is valid.
  ///
  /// Returns true if the token is present and not empty.
  /// This is a basic validation and doesn't verify with the server.
  @override
  bool get isAuthenticated {
    try {
      _validateToken();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Handles authentication errors from API responses.
  ///
  /// [statusCode] is the HTTP status code from the API response.
  /// [responseBody] is the response body from the API.
  /// Throws appropriate [AuthException] based on the error.
  @visibleForTesting
  @override
  void handleAuthError(int statusCode, String? responseBody) {
    _logger.warning('Authentication error: $statusCode, $responseBody');
    
    if (statusCode == 401) {
      throw AuthException.unauthorized(responseBody);
    } else if (statusCode == 403) {
      throw AuthException.invalidToken(responseBody);
    }
  }
}