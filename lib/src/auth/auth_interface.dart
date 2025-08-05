import '../exceptions/auth_exception.dart';

/// Common interface for authentication managers.
///
/// This interface defines the contract that both regular and server-only
/// authentication managers must implement.
abstract class AuthManagerInterface {
  /// Gets the authentication headers for API requests.
  ///
  /// Returns a map containing the Authorization header.
  /// Throws [AuthException] if token is invalid or missing.
  Map<String, String> getAuthHeaders();

  /// Gets the current authentication token.
  ///
  /// Returns the access token for API requests.
  /// Throws [AuthException] if token is invalid or missing.
  String getToken();

  /// Checks if the client is authenticated.
  ///
  /// Returns true if a valid token is available.
  bool get isAuthenticated;

  /// Handles authentication errors from API responses.
  ///
  /// Throws appropriate [AuthException] based on the error code.
  void handleAuthError(int statusCode, String? responseBody);
}