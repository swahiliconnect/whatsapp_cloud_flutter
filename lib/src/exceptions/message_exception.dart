import 'api_exception.dart';

/// Exception thrown when message-related errors occur.
class MessageException implements Exception {
  /// Error code for the message error
  final String code;

  /// Human-readable error message
  final String message;

  /// Original exception that caused this message exception
  final dynamic originalException;

  /// Creates a new message exception.
  ///
  /// [code] is a machine-readable error code.
  /// [message] is a human-readable error message.
  /// [originalException] is the underlying exception if available.
  MessageException({
    required this.code,
    required this.message,
    this.originalException,
  });

  /// Creates a message exception for invalid recipient.
  factory MessageException.invalidRecipient([String? details]) {
    return MessageException(
      code: 'invalid_recipient',
      message: 'Invalid recipient phone number${details != null ? ': $details' : ''}',
    );
  }

  /// Creates a message exception for invalid message content.
  factory MessageException.invalidContent([String? details]) {
    return MessageException(
      code: 'invalid_content',
      message: 'Invalid message content${details != null ? ': $details' : ''}',
    );
  }

  /// Creates a message exception for delivery failure.
  factory MessageException.deliveryFailure([dynamic originalException]) {
    return MessageException(
      code: 'delivery_failure',
      message: 'Failed to deliver message',
      originalException: originalException,
    );
  }

  /// Creates a message exception for template not found.
  factory MessageException.templateNotFound(String templateName) {
    return MessageException(
      code: 'template_not_found',
      message: 'Template not found: $templateName',
    );
  }

  /// Creates a message exception for template parameter error.
  factory MessageException.templateParameterError(String details) {
    return MessageException(
      code: 'template_parameter_error',
      message: 'Invalid template parameters: $details',
    );
  }

  /// Creates a message exception from an API exception.
  factory MessageException.fromApiException(ApiException exception) {
    String code = 'message_error';
    
    // Try to extract a more specific error code from the response
    if (exception.responseBody is Map) {
      final errorCode = exception.responseBody['error']?['code'];
      if (errorCode != null && errorCode is String) {
        code = errorCode;
      }
    }
    
    return MessageException(
      code: code,
      message: exception.message,
      originalException: exception,
    );
  }

  @override
  String toString() {
    return 'MessageException: [$code] $message';
  }
}