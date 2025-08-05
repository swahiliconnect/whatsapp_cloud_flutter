import '../exceptions/auth_exception.dart';
import '../utils/logger.dart';
import 'auth_interface.dart';

/// Server-only token storage implementation.
///
/// This is a pure Dart implementation that doesn't depend on Flutter
/// or shared_preferences for server environments.
abstract class ServerTokenStorage {
  /// Saves a token to storage.
  Future<void> saveToken(String token);

  /// Retrieves a token from storage.
  Future<String?> getToken();

  /// Deletes a token from storage.
  Future<void> deleteToken();

  /// Checks if a token exists in storage.
  Future<bool> hasToken();
}

/// In-memory token storage implementation for server environments.
class ServerInMemoryTokenStorage implements ServerTokenStorage {
  /// In-memory token storage
  String? _token;

  /// Logger for token storage operations
  final Logger _logger;

  /// Creates a new in-memory token storage.
  ///
  /// [logger] is used for logging token storage events.
  ServerInMemoryTokenStorage({
    required Logger logger,
  }) : _logger = logger;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
    _logger.debug('Token saved to in-memory storage');
  }

  @override
  Future<String?> getToken() async {
    _logger.debug('Token retrieved from in-memory storage');
    return _token;
  }

  @override
  Future<void> deleteToken() async {
    _token = null;
    _logger.debug('Token deleted from in-memory storage');
  }

  @override
  Future<bool> hasToken() async {
    final hasToken = _token != null;
    _logger.debug('Token existence check: $hasToken');
    return hasToken;
  }
}

/// Server-only authentication manager for WhatsApp Cloud API.
///
/// This version doesn't depend on Flutter or shared_preferences.
class ServerAuthManager implements AuthManagerInterface {
  /// Access token for WhatsApp Cloud API
  final String accessToken;

  /// Optional token storage for persistent token storage
  final ServerTokenStorage? tokenStorage;

  /// Logger for authentication-related events
  final Logger _logger;

  /// Creates a new server authentication manager.
  ///
  /// [accessToken] is the WhatsApp Cloud API access token.
  /// [tokenStorage] is an optional mechanism for persistent token storage.
  /// [logger] is used for logging authentication events.
  ServerAuthManager({
    required this.accessToken,
    this.tokenStorage,
    required Logger logger,
  }) : _logger = logger {
    _validateToken();
    _logger.debug('ServerAuthManager initialized');
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
  String getToken() {
    try {
      _validateToken();
      return accessToken;
    } catch (e) {
      _logger.error('Failed to get authentication token', e);
      throw AuthException.unauthorized(e);
    }
  }

  /// Gets the authentication headers for API requests.
  ///
  /// Returns a map containing the Authorization header.
  /// Throws [AuthException] if token is invalid or missing.
  Map<String, String> getAuthHeaders() {
    final token = getToken();
    return {'Authorization': 'Bearer $token'};
  }

  /// Checks if the client is authenticated.
  ///
  /// Returns true if a valid token is available.
  bool get isAuthenticated {
    try {
      getToken();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Handles authentication errors from API responses.
  ///
  /// Throws appropriate [AuthException] based on the error code.
  void handleAuthError(int statusCode, String? responseBody) {
    _logger.warning('Authentication error: $statusCode - $responseBody');
    
    switch (statusCode) {
      case 401:
        throw AuthException.unauthorized(responseBody);
      case 403:
        throw AuthException.invalidToken(responseBody);
      default:
        throw AuthException.unauthorized('Authentication failed with status: $statusCode');
    }
  }
}