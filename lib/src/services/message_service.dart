import 'package:meta/meta.dart';

import '../client/api_client.dart';
import '../config/constants.dart';
import '../exceptions/api_exception.dart';
import '../exceptions/message_exception.dart';
import '../models/contacts/contact.dart';
import '../models/messages/interactive_message.dart';
import '../models/messages/location_message.dart';
import '../models/messages/media_message.dart';
import '../models/messages/message.dart';
import '../models/messages/text_message.dart';
import '../models/messages/advanced_interactive_message.dart';
import '../models/responses/message_response.dart';
import '../models/templatez/template.dart';
import '../utils/logger.dart';

/// Service for sending various types of messages through WhatsApp Cloud API.
class MessageService {
  /// API client for making requests
  final ApiClient _apiClient;

  /// Phone number ID for sending messages
  final String _phoneNumberId;

  /// Logger for message service events
  final Logger _logger;

  /// Creates a new message service.
  ///
  /// [apiClient] is the API client for making requests.
  /// [phoneNumberId] is the WhatsApp Business Account phone number ID.
  /// [logger] is used for logging message service events.
  MessageService({
    required ApiClient apiClient,
    required String phoneNumberId,
    required Logger logger,
  })  : _apiClient = apiClient,
        _phoneNumberId = phoneNumberId,
        _logger = logger {
    _logger.debug('MessageService initialized');
  }

  /// Sends a text message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [text] is the message text.
  /// [previewUrl] determines whether to show URL previews.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendTextMessage({
    required String recipient,
    required String text,
    bool previewUrl = false,
  }) async {
    _logger.info('Sending text message to $recipient');

    final message = TextMessage(
      recipient: recipient,
      text: text,
      previewUrl: previewUrl,
    );

    return sendMessage(message);
  }

  /// Sends an image message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [source] specifies whether the image is identified by ID or URL.
  /// [mediaId] is the ID of the image (required if source is ID).
  /// [mediaUrl] is the URL of the image (required if source is URL).
  /// [caption] is an optional caption for the image.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendImageMessage({
    required String recipient,
    required MediaSource source,
    String? mediaId,
    String? mediaUrl,
    String? caption,
  }) async {
    _logger.info('Sending image message to $recipient');

    final message = ImageMessage(
      recipient: recipient,
      source: source,
      mediaId: mediaId,
      mediaUrl: mediaUrl,
      caption: caption,
    );

    return sendMessage(message);
  }

  /// Sends a video message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [source] specifies whether the video is identified by ID or URL.
  /// [mediaId] is the ID of the video (required if source is ID).
  /// [mediaUrl] is the URL of the video (required if source is URL).
  /// [caption] is an optional caption for the video.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendVideoMessage({
    required String recipient,
    required MediaSource source,
    String? mediaId,
    String? mediaUrl,
    String? caption,
  }) async {
    _logger.info('Sending video message to $recipient');

    final message = VideoMessage(
      recipient: recipient,
      source: source,
      mediaId: mediaId,
      mediaUrl: mediaUrl,
      caption: caption,
    );

    return sendMessage(message);
  }

  /// Sends an audio message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [source] specifies whether the audio is identified by ID or URL.
  /// [mediaId] is the ID of the audio (required if source is ID).
  /// [mediaUrl] is the URL of the audio (required if source is URL).
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendAudioMessage({
    required String recipient,
    required MediaSource source,
    String? mediaId,
    String? mediaUrl,
  }) async {
    _logger.info('Sending audio message to $recipient');

    final message = AudioMessage(
      recipient: recipient,
      source: source,
      mediaId: mediaId,
      mediaUrl: mediaUrl,
    );

    return sendMessage(message);
  }

  /// Sends a document message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [source] specifies whether the document is identified by ID or URL.
  /// [mediaId] is the ID of the document (required if source is ID).
  /// [mediaUrl] is the URL of the document (required if source is URL).
  /// [caption] is an optional caption for the document.
  /// [filename] is an optional filename to display.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendDocumentMessage({
    required String recipient,
    required MediaSource source,
    String? mediaId,
    String? mediaUrl,
    String? caption,
    String? filename,
  }) async {
    _logger.info('Sending document message to $recipient');

    final message = DocumentMessage(
      recipient: recipient,
      source: source,
      mediaId: mediaId,
      mediaUrl: mediaUrl,
      caption: caption,
      filename: filename,
    );

    return sendMessage(message);
  }

  /// Sends a sticker message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [source] specifies whether the sticker is identified by ID or URL.
  /// [mediaId] is the ID of the sticker (required if source is ID).
  /// [mediaUrl] is the URL of the sticker (required if source is URL).
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendStickerMessage({
    required String recipient,
    required MediaSource source,
    String? mediaId,
    String? mediaUrl,
  }) async {
    _logger.info('Sending sticker message to $recipient');

    final message = StickerMessage(
      recipient: recipient,
      source: source,
      mediaId: mediaId,
      mediaUrl: mediaUrl,
    );

    return sendMessage(message);
  }

  /// Sends a location message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [latitude] is the latitude coordinate.
  /// [longitude] is the longitude coordinate.
  /// [name] is an optional name for the location.
  /// [address] is an optional address for the location.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendLocationMessage({
    required String recipient,
    required double latitude,
    required double longitude,
    String? name,
    String? address,
  }) async {
    _logger.info('Sending location message to $recipient');

    final message = LocationMessage(
      recipient: recipient,
      latitude: latitude,
      longitude: longitude,
      name: name,
      address: address,
    );

    return sendMessage(message);
  }

  /// Sends a contact message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [contacts] is the list of contacts to send.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendContactMessage({
    required String recipient,
    required List<Contact> contacts,
  }) async {
    _logger.info('Sending contact message to $recipient');
    
    if (contacts.isEmpty) {
      throw MessageException.invalidContent('At least one contact is required');
    }
    
    // Validate all contacts
    for (final contact in contacts) {
      if (!contact.isValid()) {
        throw MessageException.invalidContent('Invalid contact data');
      }
    }
    
    try {
      final contactsJson = contacts.map((contact) => contact.toJson()).toList();
      
      final requestData = {
        'messaging_product': 'whatsapp',
        'recipient_type': 'individual',
        'to': recipient,
        'type': 'contacts',
        'contacts': contactsJson,
      };
      
      final endpoint = '/$_phoneNumberId/${Constants.messagePath}';
      final response = await _apiClient.post(endpoint, data: requestData);
      
      return MessageResponse.fromApiResponse(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      _logger.error('Failed to send contact message', e);
      throw MessageException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to send contact message', e);
      throw MessageException(
        code: 'send_contact_error',
        message: 'Failed to send contact message: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Sends an interactive message with buttons.
  ///
  /// [recipient] is the recipient's phone number.
  /// [bodyText] is the main message text.
  /// [buttons] is the list of buttons to display.
  /// [headerText] is optional text for the header.
  /// [footerText] is optional text for the footer.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendButtonMessage({
    required String recipient,
    required String bodyText,
    required List<Button> buttons,
    String? headerText,
    String? footerText,
  }) async {
    _logger.info('Sending button message to $recipient');

    final message = InteractiveMessageFactory.createButtonMessage(
      recipient: recipient,
      bodyText: bodyText,
      buttons: buttons,
      headerText: headerText,
      footerText: footerText,
    );

    return sendMessage(message);
  }

  /// Sends an interactive message with a list.
  ///
  /// [recipient] is the recipient's phone number.
  /// [bodyText] is the main message text.
  /// [buttonText] is the text for the button that opens the list.
  /// [sections] is the list of sections to display.
  /// [headerText] is optional text for the header.
  /// [footerText] is optional text for the footer.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendListMessage({
    required String recipient,
    required String bodyText,
    required String buttonText,
    required List<Section> sections,
    String? headerText,
    String? footerText,
  }) async {
    _logger.info('Sending list message to $recipient');

    final message = InteractiveMessageFactory.createListMessage(
      recipient: recipient,
      bodyText: bodyText,
      buttonText: buttonText,
      sections: sections,
      headerText: headerText,
      footerText: footerText,
    );

    return sendMessage(message);
  }

  /// Sends a template message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [template] is the template to send.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendTemplateMessage({
    required String recipient,
    required Template template,
  }) async {
    _logger.info('Sending template message to $recipient');
    
    if (!template.isValid()) {
      throw MessageException.invalidContent('Invalid template data');
    }
    
    try {
      final requestData = {
        'messaging_product': 'whatsapp',
        'recipient_type': 'individual',
        'to': recipient,
        'type': 'template',
        'template': template.toJson(),
      };
      
      final endpoint = '/$_phoneNumberId/${Constants.messagePath}';
      final response = await _apiClient.post(endpoint, data: requestData);
      
      return MessageResponse.fromApiResponse(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      _logger.error('Failed to send template message', e);
      throw MessageException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to send template message', e);
      throw MessageException(
        code: 'send_template_error',
        message: 'Failed to send template message: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Sends a reaction to a message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [messageId] is the ID of the message to react to.
  /// [emoji] is the emoji reaction (must be a single emoji).
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendReaction({
    required String recipient,
    required String messageId,
    required String emoji,
  }) async {
    _logger.info('Sending reaction to message $messageId');
    
    // Validate emoji (should be a single emoji)
    if (emoji.isEmpty) {
      throw MessageException.invalidContent('Emoji cannot be empty');
    }
    
    try {
      final requestData = {
        'messaging_product': 'whatsapp',
        'recipient_type': 'individual',
        'to': recipient,
        'type': 'reaction',
        'reaction': {
          'message_id': messageId,
          'emoji': emoji,
        },
      };
      
      final endpoint = '/$_phoneNumberId/${Constants.messagePath}';
      final response = await _apiClient.post(endpoint, data: requestData);
      
      return MessageResponse.fromApiResponse(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      _logger.error('Failed to send reaction', e);
      throw MessageException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to send reaction', e);
      throw MessageException(
        code: 'send_reaction_error',
        message: 'Failed to send reaction: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Sends a CTA URL interactive message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [bodyText] is the main message text.
  /// [buttonText] is the text for the CTA button.
  /// [url] is the URL to open when button is pressed.
  /// [headerText] is optional header text.
  /// [footerText] is optional footer text.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendCtaUrlMessage({
    required String recipient,
    required String bodyText,
    required String buttonText,
    required String url,
    String? headerText,
    String? footerText,
  }) async {
    _logger.info('Sending CTA URL message to $recipient');

    final message = CtaUrlMessage(
      recipient: recipient,
      bodyText: bodyText,
      buttonText: buttonText,
      url: url,
      headerText: headerText,
      footerText: footerText,
    );

    return sendMessage(message);
  }

  /// Sends a location request message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [bodyText] is the message asking for location.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendLocationRequestMessage({
    required String recipient,
    required String bodyText,
  }) async {
    _logger.info('Sending location request message to $recipient');

    final message = LocationRequestMessage(
      recipient: recipient,
      bodyText: bodyText,
    );

    return sendMessage(message);
  }

  /// Sends an address request message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [bodyText] is the message asking for address.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendAddressMessage({
    required String recipient,
    required String bodyText,
  }) async {
    _logger.info('Sending address request message to $recipient');

    final message = AddressMessage(
      recipient: recipient,
      bodyText: bodyText,
    );

    return sendMessage(message);
  }

  /// Marks a message as read.
  ///
  /// [messageId] is the ID of the message to mark as read.
  /// Returns a message response indicating success/failure.
  Future<MessageResponse> markMessageAsRead({
    required String messageId,
  }) async {
    _logger.info('Marking message as read: $messageId');
    
    try {
      final requestData = {
        'messaging_product': 'whatsapp',
        'status': 'read',
        'message_id': messageId,
      };
      
      final endpoint = '/$_phoneNumberId/${Constants.messagePath}';
      final response = await _apiClient.post(endpoint, data: requestData);
      
      return MessageResponse.fromApiResponse(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      _logger.error('Failed to mark message as read', e);
      throw MessageException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to mark message as read', e);
      throw MessageException(
        code: 'mark_read_error',
        message: 'Failed to mark message as read: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Sends a generic message.
  ///
  /// [message] is the message to send.
  /// Returns a message response with the message ID if successful.
  @visibleForTesting
  Future<MessageResponse> sendMessage(Message message) async {
    if (!message.isValid()) {
      throw MessageException.invalidContent();
    }
    
    try {
      final messageJson = message.toJson();
      final endpoint = '/$_phoneNumberId/${Constants.messagePath}';
      final response = await _apiClient.post(endpoint, data: messageJson);
      
      return MessageResponse.fromApiResponse(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      _logger.error('Failed to send message', e);
      throw MessageException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to send message', e);
      throw MessageException(
        code: 'send_message_error',
        message: 'Failed to send message: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Marks a message as read (legacy method).
  ///
  /// [messageId] is the ID of the message to mark as read.
  /// Returns true if successful, false otherwise.
  /// 
  /// @deprecated Use [markMessageAsRead] instead.
  @deprecated
  Future<bool> markAsRead(String messageId) async {
    _logger.info('Marking message $messageId as read');
    
    try {
      final requestData = {
        'messaging_product': 'whatsapp',
        'status': 'read',
        'message_id': messageId,
      };
      
      final endpoint = '/$_phoneNumberId/${Constants.messagePath}';
      await _apiClient.post(endpoint, data: requestData);
      
      return true;
    } on ApiException catch (e) {
      _logger.error('Failed to mark message as read', e);
      throw MessageException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to mark message as read', e);
      throw MessageException(
        code: 'mark_as_read_error',
        message: 'Failed to mark message as read: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Gets metadata for a specific message.
  ///
  /// [messageId] is the ID of the message to retrieve.
  /// Returns a map containing message metadata if successful.
  Future<Map<String, dynamic>> getMessageStatus(String messageId) async {
    _logger.info('Getting status for message $messageId');
    
    try {
      final endpoint = '/$_phoneNumberId/${Constants.messagePath}/$messageId';
      final response = await _apiClient.get(endpoint);
      
      return response as Map<String, dynamic>;
    } on ApiException catch (e) {
      _logger.error('Failed to get message status', e);
      throw MessageException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to get message status', e);
      throw MessageException(
        code: 'get_status_error',
        message: 'Failed to get message status: ${e.toString()}',
        originalException: e,
      );
    }
  }
}