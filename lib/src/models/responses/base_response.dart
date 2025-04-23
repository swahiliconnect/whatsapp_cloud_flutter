import 'package:meta/meta.dart';

/// Base class for all API responses.
///
/// Provides common fields and functionality for all response types.
@immutable
class BaseResponse {
  /// Whether the API call was successful
  final bool successful;

  /// Error message, if the call failed
  final String? errorMessage;

  /// Error code, if the call failed
  final String? errorCode;

  /// Raw response data from the API
  final Map<String, dynamic>? data;

  /// Creates a new base response.
  ///
  /// [successful] indicates if the API call succeeded.
  /// [errorMessage] is the error message if the call failed.
  /// [errorCode] is the error code if the call failed.
  /// [data] is the raw response data from the API.
  const BaseResponse({
    required this.successful,
    this.errorMessage,
    this.errorCode,
    this.data,
  });

  /// Factory method for creating a successful response.
  ///
  /// [data] is the raw response data from the API.
  /// Returns a successful response instance.
  factory BaseResponse.success(Map<String, dynamic>? data) {
    return BaseResponse(
      successful: true,
      data: data,
    );
  }

  /// Factory method for creating a failed response.
  ///
  /// [errorMessage] is the error message.
  /// [errorCode] is the error code.
  /// [data] is the raw response data from the API.
  /// Returns a failed response instance.
  factory BaseResponse.failure({
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? data,
  }) {
    return BaseResponse(
      successful: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
      data: data,
    );
  }

  /// Error information for display purposes.
  ///
  /// Returns null if the response was successful.
  /// Otherwise, returns a map with error information.
  Map<String, String>? get error {
    if (successful) return null;
    
    return {
      'message': errorMessage ?? 'Unknown error',
      'code': errorCode ?? 'unknown_error',
    };
  }

  @override
  String toString() {
    if (successful) {
      return 'BaseResponse(successful: true, data: $data)';
    } else {
      return 'BaseResponse(successful: false, errorCode: $errorCode, errorMessage: $errorMessage)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BaseResponse &&
        other.successful == successful &&
        other.errorMessage == errorMessage &&
        other.errorCode == errorCode &&
        _mapEquals(other.data, data);
  }

  bool _mapEquals<K, V>(Map<K, V>? map1, Map<K, V>? map2) {
    if (identical(map1, map2)) return true;
    if (map1 == null || map2 == null) return map1 == map2;
    if (map1.length != map2.length) return false;
    
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    
    return true;
  }

  @override
  int get hashCode => successful.hashCode ^ errorMessage.hashCode ^ errorCode.hashCode ^ data.hashCode;
}