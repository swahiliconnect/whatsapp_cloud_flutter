import 'package:meta/meta.dart';

import 'base_response.dart';

/// Response from sending a message via WhatsApp Cloud API.
///
/// Contains the message ID and status information.
@immutable
class MessageResponse extends BaseResponse {
  /// ID of the sent message (if successful)
  final String? messageId;

  /// Status of the message (if returned by the API)
  final String? status;

  /// Creates a new message response.
  ///
  /// [successful] indicates if the message was sent successfully.
  /// [messageId] is the ID of the sent message.
  /// [status] is the status of the message.
  /// [errorMessage] is the error message if the message wasn't sent.
  /// [errorCode] is the error code if the message wasn't sent.
  /// [data] is the raw response data from the API.
  const MessageResponse({
    required bool successful,
    this.messageId,
    this.status,
    String? errorMessage,
    String? errorCode,
    Map<String, dynamic>? data,
  }) : super(
          successful: successful,
          errorMessage: errorMessage,
          errorCode: errorCode,
          data: data,
        );

  /// Factory method for creating a successful message response.
  ///
  /// [messageId] is the ID of the sent message.
  /// [status] is the status of the message.
  /// [data] is the raw response data from the API.
  /// Returns a successful response instance.
  factory MessageResponse.success({
    required String messageId,
    String? status,
    Map<String, dynamic>? data,
  }) {
    return MessageResponse(
      successful: true,
      messageId: messageId,
      status: status,
      data: data,
    );
  }

  /// Factory method for creating a failed message response.
  ///
  /// [errorMessage] is the error message.
  /// [errorCode] is the error code.
  /// [data] is the raw response data from the API.
  /// Returns a failed response instance.
  factory MessageResponse.failure({
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? data,
  }) {
    return MessageResponse(
      successful: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
      data: data,
    );
  }

  /// Factory method for parsing API response into a message response.
  ///
  /// [apiResponse] is the raw API response data.
  /// Returns a message response instance based on the API response.
  factory MessageResponse.fromApiResponse(Map<String, dynamic> apiResponse) {
    try {
      // Check for error in response
      if (apiResponse.containsKey('error')) {
        final error = apiResponse['error'];
        
        return MessageResponse.failure(
          errorMessage: (error['message'] as String?) ?? 'Unknown error',
          errorCode: error['code']?.toString(),
          data: apiResponse,
        );
      }
      
      // Extract message ID from successful response
      if (apiResponse.containsKey('messages') && apiResponse['messages'] is List) {
        final messages = apiResponse['messages'] as List;
        
        if (messages.isNotEmpty && messages[0] is Map) {
          final message = messages[0] as Map;
          final messageId = message['id']?.toString();
          
          if (messageId != null) {
            return MessageResponse.success(
              messageId: messageId,
              status: 'sent', // Default status for just-sent messages
              data: apiResponse,
            );
          }
        }
      }
      
      // If we can't parse correctly, return failure
      return MessageResponse.failure(
        errorMessage: 'Failed to parse message response',
        errorCode: 'parse_error',
        data: apiResponse,
      );
    } catch (e) {
      return MessageResponse.failure(
        errorMessage: 'Failed to parse message response: ${e.toString()}',
        errorCode: 'parse_error',
        data: apiResponse,
      );
    }
  }

  @override
  String toString() {
    if (successful) {
      return 'MessageResponse(successful: true, messageId: $messageId, status: $status)';
    } else {
      return 'MessageResponse(successful: false, errorCode: $errorCode, errorMessage: $errorMessage)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageResponse &&
        other.successful == successful &&
        other.messageId == messageId &&
        other.status == status &&
        other.errorMessage == errorMessage &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode => successful.hashCode ^ messageId.hashCode ^ status.hashCode ^ errorMessage.hashCode ^ errorCode.hashCode;
}

/// Response from a message template operation.
@immutable
class TemplateResponse extends BaseResponse {
  /// ID of the template (if successful)
  final String? templateId;

  /// Status of the template
  final String? status;

  /// Creates a new template response.
  ///
  /// [successful] indicates if the operation was successful.
  /// [templateId] is the ID of the template.
  /// [status] is the status of the template.
  /// [errorMessage] is the error message if the operation failed.
  /// [errorCode] is the error code if the operation failed.
  /// [data] is the raw response data from the API.
  const TemplateResponse({
    required bool successful,
    this.templateId,
    this.status,
    String? errorMessage,
    String? errorCode,
    Map<String, dynamic>? data,
  }) : super(
          successful: successful,
          errorMessage: errorMessage,
          errorCode: errorCode,
          data: data,
        );

  /// Factory method for creating a successful template response.
  ///
  /// [templateId] is the ID of the template.
  /// [status] is the status of the template.
  /// [data] is the raw response data from the API.
  /// Returns a successful response instance.
  factory TemplateResponse.success({
    required String templateId,
    String? status,
    Map<String, dynamic>? data,
  }) {
    return TemplateResponse(
      successful: true,
      templateId: templateId,
      status: status,
      data: data,
    );
  }

  /// Factory method for creating a failed template response.
  ///
  /// [errorMessage] is the error message.
  /// [errorCode] is the error code.
  /// [data] is the raw response data from the API.
  /// Returns a failed response instance.
  factory TemplateResponse.failure({
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? data,
  }) {
    return TemplateResponse(
      successful: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
      data: data,
    );
  }

  @override
  String toString() {
    if (successful) {
      return 'TemplateResponse(successful: true, templateId: $templateId, status: $status)';
    } else {
      return 'TemplateResponse(successful: false, errorCode: $errorCode, errorMessage: $errorMessage)';
    }
  }
}

/// Response from a media operation.
@immutable
class MediaResponse extends BaseResponse {
  /// ID of the media (if successful)
  final String? mediaId;

  /// URL of the media (if available)
  final String? mediaUrl;

  /// Creates a new media response.
  ///
  /// [successful] indicates if the operation was successful.
  /// [mediaId] is the ID of the media.
  /// [mediaUrl] is the URL of the media.
  /// [errorMessage] is the error message if the operation failed.
  /// [errorCode] is the error code if the operation failed.
  /// [data] is the raw response data from the API.
  const MediaResponse({
    required bool successful,
    this.mediaId,
    this.mediaUrl,
    String? errorMessage,
    String? errorCode,
    Map<String, dynamic>? data,
  }) : super(
          successful: successful,
          errorMessage: errorMessage,
          errorCode: errorCode,
          data: data,
        );

  /// Factory method for creating a successful media response.
  ///
  /// [mediaId] is the ID of the media.
  /// [mediaUrl] is the URL of the media.
  /// [data] is the raw response data from the API.
  /// Returns a successful response instance.
  factory MediaResponse.success({
    String? mediaId,
    String? mediaUrl,
    Map<String, dynamic>? data,
  }) {
    return MediaResponse(
      successful: true,
      mediaId: mediaId,
      mediaUrl: mediaUrl,
      data: data,
    );
  }

  /// Factory method for creating a failed media response.
  ///
  /// [errorMessage] is the error message.
  /// [errorCode] is the error code.
  /// [data] is the raw response data from the API.
  /// Returns a failed response instance.
  factory MediaResponse.failure({
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? data,
  }) {
    return MediaResponse(
      successful: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
      data: data,
    );
  }

  @override
  String toString() {
    if (successful) {
      return 'MediaResponse(successful: true, mediaId: $mediaId, mediaUrl: $mediaUrl)';
    } else {
      return 'MediaResponse(successful: false, errorCode: $errorCode, errorMessage: $errorMessage)';
    }
  }
}