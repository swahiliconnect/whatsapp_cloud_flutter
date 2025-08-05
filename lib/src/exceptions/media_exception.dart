import 'api_exception.dart';

/// Exception thrown when media-related errors occur.
class MediaException implements Exception {
  /// Error code for the media error
  final String code;

  /// Human-readable error message
  final String message;

  /// Original exception that caused this media exception
  final dynamic originalException;

  /// Creates a new media exception.
  ///
  /// [code] is a machine-readable error code.
  /// [message] is a human-readable error message.
  /// [originalException] is the underlying exception if available.
  MediaException({
    required this.code,
    required this.message,
    this.originalException,
  });

  /// Creates a media exception for unsupported media type.
  factory MediaException.unsupportedMediaType(String mediaType) {
    return MediaException(
      code: 'unsupported_media_type',
      message: 'Unsupported media type: $mediaType',
    );
  }

  /// Creates a media exception for file size exceeded.
  factory MediaException.fileSizeExceeded(int sizeBytes, int maxSizeBytes) {
    return MediaException(
      code: 'file_size_exceeded',
      message: 'File size (${sizeBytes / 1024 / 1024}MB) exceeds maximum allowed (${maxSizeBytes / 1024 / 1024}MB)',
    );
  }

  /// Creates a media exception for upload failure.
  factory MediaException.uploadFailure([dynamic originalException]) {
    return MediaException(
      code: 'upload_failure',
      message: 'Failed to upload media file',
      originalException: originalException,
    );
  }

  /// Creates a media exception for download failure.
  factory MediaException.downloadFailure([dynamic originalException]) {
    return MediaException(
      code: 'download_failure',
      message: 'Failed to download media file',
      originalException: originalException,
    );
  }

  /// Creates a media exception for invalid media ID.
  factory MediaException.invalidMediaId(String mediaId) {
    return MediaException(
      code: 'invalid_media_id',
      message: 'Invalid media ID: $mediaId',
    );
  }

  /// Creates a media exception for file not found.
  factory MediaException.fileNotFound(String path) {
    return MediaException(
      code: 'file_not_found',
      message: 'File not found: $path',
    );
  }

  /// Creates a media exception from an API exception.
  factory MediaException.fromApiException(ApiException exception) {
    String code = 'media_error';
    
    // Try to extract a more specific error code from the response
    if (exception.responseBody is Map) {
      final errorCode = exception.responseBody['error']?['code'];
      if (errorCode != null && errorCode is String) {
        code = errorCode;
      }
    }
    
    return MediaException(
      code: code,
      message: exception.message,
      originalException: exception,
    );
  }

  @override
  String toString() {
    return 'MediaException: [$code] $message';
  }
}