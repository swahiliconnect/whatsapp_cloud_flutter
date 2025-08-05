import 'package:shared_preferences/shared_preferences.dart';

import '../exceptions/auth_exception.dart';
import '../utils/logger.dart';

/// Abstract interface for token storage implementations.
abstract class TokenStorage {
  /// Saves a token to persistent storage.
  Future<void> saveToken(String token);

  /// Retrieves a token from persistent storage.
  Future<String?> getToken();

  /// Deletes a token from persistent storage.
  Future<void> deleteToken();

  /// Checks if a token exists in persistent storage.
  Future<bool> hasToken();
}

/// Implements token storage using SharedPreferences.
class SharedPreferencesTokenStorage implements TokenStorage {
  /// Key used for storing the token in SharedPreferences
  static const String _tokenKey = 'whatsapp_cloud_api_token';

  /// Logger for token storage operations
  final Logger _logger;

  /// Creates a new SharedPreferences-based token storage.
  ///
  /// [logger] is used for logging token storage events.
  SharedPreferencesTokenStorage({
    required Logger logger,
  }) : _logger = logger;

  @override
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      _logger.debug('Token saved to SharedPreferences');
    } catch (e) {
      _logger.error('Failed to save token to SharedPreferences', e);
      throw AuthException.tokenStorageFailure(e);
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      _logger.debug('Token retrieved from SharedPreferences');
      return token;
    } catch (e) {
      _logger.error('Failed to retrieve token from SharedPreferences', e);
      throw AuthException.tokenStorageFailure(e);
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      _logger.debug('Token deleted from SharedPreferences');
    } catch (e) {
      _logger.error('Failed to delete token from SharedPreferences', e);
      throw AuthException.tokenStorageFailure(e);
    }
  }

  @override
  Future<bool> hasToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasToken = prefs.containsKey(_tokenKey);
      _logger.debug('Token existence check: $hasToken');
      return hasToken;
    } catch (e) {
      _logger.error('Failed to check token existence in SharedPreferences', e);
      throw AuthException.tokenStorageFailure(e);
    }
  }
}

/// In-memory token storage implementation for testing.
class InMemoryTokenStorage implements TokenStorage {
  /// In-memory token storage
  String? _token;

  /// Logger for token storage operations
  final Logger _logger;

  /// Creates a new in-memory token storage.
  ///
  /// [logger] is used for logging token storage events.
  InMemoryTokenStorage({
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