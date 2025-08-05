import 'dart:convert';

import 'package:meta/meta.dart';

import '../utils/logger.dart';

/// Types of WhatsApp webhook notifications.
enum WebhookNotificationType {
  /// Incoming message from a user
  message,

  /// Status update for a message (delivered, read, etc.)
  status,

  /// Account-related notifications
  account,

  /// Unknown or unsupported notification type
  unknown,
}

/// Base class for all webhook events.
@immutable
abstract class WebhookEvent {
  /// Type of the webhook notification
  final WebhookNotificationType type;

  /// Raw JSON payload from the webhook
  final Map<String, dynamic> rawPayload;

  /// Creates a new webhook event.
  ///
  /// [type] is the type of webhook notification.
  /// [rawPayload] is the raw JSON payload from the webhook.
  const WebhookEvent({
    required this.type,
    required this.rawPayload,
  });
}

/// Represents an incoming message event from a user.
@immutable
class MessageEvent extends WebhookEvent {
  /// ID of the received message
  final String messageId;

  /// Timestamp when the message was sent
  final DateTime timestamp;

  /// Sender's phone number
  final String from;

  /// Type of message (text, image, etc.)
  final String messageType;

  /// Text content if it's a text message
  final String? text;

  /// Message object containing all message details
  final Map<String, dynamic> message;

  /// Creates a new message event.
  ///
  /// [messageId] is the ID of the received message.
  /// [timestamp] is when the message was sent.
  /// [from] is the sender's phone number.
  /// [messageType] is the type of message.
  /// [text] is the text content if it's a text message.
  /// [message] is the complete message object.
  /// [rawPayload] is the raw JSON payload from the webhook.
  const MessageEvent({
    required this.messageId,
    required this.timestamp,
    required this.from,
    required this.messageType,
    this.text,
    required this.message,
    required Map<String, dynamic> rawPayload,
  }) : super(
          type: WebhookNotificationType.message,
          rawPayload: rawPayload,
        );

  /// Factory to create a message event from a webhook payload.
  factory MessageEvent.fromJson(Map<String, dynamic> json) {
    try {
      final entry = json['entry'][0];
      final changes = entry['changes'][0];
      final value = changes['value'];
      final messages = value['messages'][0];

      final messageId = messages['id'] as String;
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        int.parse(messages['timestamp'].toString()) * 1000,
      );
      final from = messages['from'] as String;
      final messageType = messages['type'] as String;

      // Extract text if it's a text message
      String? textContent;
      if (messageType == 'text' && messages is Map && messages.containsKey('text')) {
        textContent = messages['text']['body'] as String;
      }

      return MessageEvent(
        messageId: messageId,
        timestamp: timestamp,
        from: from,
        messageType: messageType,
        text: textContent,
        message: messages as Map<String, dynamic>,
        rawPayload: json,
      );
    } catch (e) {
      throw FormatException('Invalid message event payload: ${e.toString()}');
    }
  }
}

/// Represents a status update event for a message.
@immutable
class StatusEvent extends WebhookEvent {
  /// ID of the message
  final String messageId;

  /// Recipient's phone number
  final String recipient;

  /// Status of the message (sent, delivered, read, etc.)
  final String status;

  /// Timestamp of the status update
  final DateTime timestamp;

  /// Conversation ID if available
  final String? conversationId;

  /// Creates a new status event.
  ///
  /// [messageId] is the ID of the message.
  /// [recipient] is the recipient's phone number.
  /// [status] is the status of the message.
  /// [timestamp] is when the status update occurred.
  /// [conversationId] is the ID of the conversation if available.
  /// [rawPayload] is the raw JSON payload from the webhook.
  const StatusEvent({
    required this.messageId,
    required this.recipient,
    required this.status,
    required this.timestamp,
    this.conversationId,
    required Map<String, dynamic> rawPayload,
  }) : super(
          type: WebhookNotificationType.status,
          rawPayload: rawPayload,
        );

  /// Factory to create a status event from a webhook payload.
  factory StatusEvent.fromJson(Map<String, dynamic> json) {
    try {
      final entry = json['entry'][0];
      final changes = entry['changes'][0];
      final value = changes['value'];
      final statuses = value['statuses'][0];

      final messageId = statuses['id'] as String;
      final recipient = statuses['recipient_id'] as String;
      final status = statuses['status'] as String;
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        int.parse(statuses['timestamp'].toString()) * 1000,
      );
      
      String? conversationId;
      if (statuses is Map && statuses.containsKey('conversation')) {
        final conversation = statuses['conversation'];
        if (conversation is Map && conversation.containsKey('id')) {
          conversationId = conversation['id'] as String;
        }
      }

      return StatusEvent(
        messageId: messageId,
        recipient: recipient,
        status: status,
        timestamp: timestamp,
        conversationId: conversationId,
        rawPayload: json,
      );
    } catch (e) {
      throw FormatException('Invalid status event payload: ${e.toString()}');
    }
  }
}

/// Represents a message status event (delivered, read, failed, etc.).
@immutable
class MessageStatusEvent extends WebhookEvent {
  /// ID of the message whose status changed
  final String messageId;

  /// New status of the message
  final String status;

  /// Timestamp when status changed
  final DateTime timestamp;

  /// Recipient's phone number
  final String recipient;

  /// Optional conversation information
  final Map<String, dynamic>? conversation;

  /// Optional pricing information
  final Map<String, dynamic>? pricing;

  /// Optional error information if status is 'failed'
  final Map<String, dynamic>? error;

  /// Creates a new message status event.
  const MessageStatusEvent({
    required this.messageId,
    required this.status,
    required this.timestamp,
    required this.recipient,
    this.conversation,
    this.pricing,
    this.error,
    required Map<String, dynamic> rawPayload,
  }) : super(
          type: WebhookNotificationType.status,
          rawPayload: rawPayload,
        );

  /// Factory to create a status event from a webhook payload.
  factory MessageStatusEvent.fromJson(Map<String, dynamic> json) {
    try {
      final entry = json['entry'][0];
      final changes = entry['changes'][0];
      final value = changes['value'];
      final statuses = value['statuses'][0];

      final messageId = statuses['id'] as String;
      final status = statuses['status'] as String;
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        int.parse(statuses['timestamp'].toString()) * 1000,
      );
      final recipient = statuses['recipient_id'] as String;

      return MessageStatusEvent(
        messageId: messageId,
        status: status,
        timestamp: timestamp,
        recipient: recipient,
        conversation: statuses['conversation'] as Map<String, dynamic>?,
        pricing: statuses['pricing'] as Map<String, dynamic>?,
        error: statuses['errors']?[0] as Map<String, dynamic>?,
        rawPayload: json,
      );
    } catch (e) {
      throw WebhookParseException('Failed to parse message status event: $e');
    }
  }

  /// Whether the message was successfully delivered
  bool get isDelivered => status == 'delivered';

  /// Whether the message was read by the recipient
  bool get isRead => status == 'read';

  /// Whether the message failed to send
  bool get isFailed => status == 'failed';

  /// Whether the message was sent successfully
  bool get isSent => status == 'sent';
}

/// Represents an account-related event.
@immutable
class AccountEvent extends WebhookEvent {
  /// Type of account event
  final String eventType;

  /// Account information
  final Map<String, dynamic> accountInfo;

  /// Creates a new account event.
  const AccountEvent({
    required this.eventType,
    required this.accountInfo,
    required Map<String, dynamic> rawPayload,
  }) : super(
          type: WebhookNotificationType.account,
          rawPayload: rawPayload,
        );

  /// Factory to create an account event from a webhook payload.
  factory AccountEvent.fromJson(Map<String, dynamic> json) {
    // Implementation depends on specific account event structure
    return AccountEvent(
      eventType: 'account_update',
      accountInfo: json,
      rawPayload: json,
    );
  }
}

/// Exception thrown when webhook payload parsing fails.
class WebhookParseException implements Exception {
  final String message;
  
  const WebhookParseException(this.message);
  
  @override
  String toString() => 'WebhookParseException: $message';
}

/// Function type for handling message events.
typedef MessageEventHandler = void Function(MessageEvent event);

/// Function type for handling status events.
typedef StatusEventHandler = void Function(StatusEvent event);

/// Function type for handling raw webhook payloads.
typedef RawWebhookHandler = void Function(Map<String, dynamic> payload);

/// Service for handling WhatsApp webhook notifications.
class WebhookService {
  /// Logger for webhook service events
  final Logger _logger;

  /// Registered handlers for message events
  final List<MessageEventHandler> _messageHandlers = [];

  /// Registered handlers for status events
  final List<StatusEventHandler> _statusHandlers = [];

  /// Registered handlers for raw webhook payloads
  final List<RawWebhookHandler> _rawHandlers = [];

  /// Creates a new webhook service.
  ///
  /// [logger] is used for logging webhook service events.
  WebhookService({
    required Logger logger,
  }) : _logger = logger {
    _logger.debug('WebhookService initialized');
  }

  /// Registers a handler for message events.
  ///
  /// [handler] is the function to call when a message event is received.
  void registerMessageHandler(MessageEventHandler handler) {
    _messageHandlers.add(handler);
    _logger.debug('Registered message handler');
  }

  /// Registers a handler for status events.
  ///
  /// [handler] is the function to call when a status event is received.
  void registerStatusHandler(StatusEventHandler handler) {
    _statusHandlers.add(handler);
    _logger.debug('Registered status handler');
  }

  /// Registers a handler for raw webhook payloads.
  ///
  /// [handler] is the function to call when any webhook is received.
  void registerRawHandler(RawWebhookHandler handler) {
    _rawHandlers.add(handler);
    _logger.debug('Registered raw webhook handler');
  }

  /// Unregisters a message handler.
  ///
  /// [handler] is the handler to remove.
  void unregisterMessageHandler(MessageEventHandler handler) {
    _messageHandlers.remove(handler);
    _logger.debug('Unregistered message handler');
  }

  /// Unregisters a status handler.
  ///
  /// [handler] is the handler to remove.
  void unregisterStatusHandler(StatusEventHandler handler) {
    _statusHandlers.remove(handler);
    _logger.debug('Unregistered status handler');
  }

  /// Unregisters a raw webhook handler.
  ///
  /// [handler] is the handler to remove.
  void unregisterRawHandler(RawWebhookHandler handler) {
    _rawHandlers.remove(handler);
    _logger.debug('Unregistered raw webhook handler');
  }

  /// Processes a webhook notification.
  ///
  /// [payload] is either a JSON string or a Map with the webhook data.
  /// Returns true if the webhook was processed, false otherwise.
  bool processWebhook(dynamic payload) {
    try {
      // Convert payload to a Map if it's a string
      final Map<String, dynamic> payloadMap = payload is String
          ? json.decode(payload) as Map<String, dynamic>
          : payload as Map<String, dynamic>;
      
      // Notify raw handlers first
      for (final handler in _rawHandlers) {
        try {
          handler(payloadMap);
        } catch (e) {
          _logger.error('Error in raw webhook handler', e);
        }
      }
      
      // Determine the notification type
      final type = _getNotificationType(payloadMap);
      
      switch (type) {
        case WebhookNotificationType.message:
          _processMessageEvent(payloadMap);
          break;
        case WebhookNotificationType.status:
          _processStatusEvent(payloadMap);
          break;
        case WebhookNotificationType.account:
          // Account events not implemented yet
          _logger.warning('Account events not implemented yet');
          return false;
        case WebhookNotificationType.unknown:
          _logger.warning('Unknown webhook notification type');
          return false;
      }
      
      return true;
    } catch (e) {
      _logger.error('Error processing webhook', e);
      return false;
    }
  }

/// Determines the type of notification from the webhook payload.
WebhookNotificationType _getNotificationType(Map<String, dynamic> payload) {
  try {
    // Check if this is a valid webhook payload
    if (!payload.containsKey('object') || payload['object'] != 'whatsapp_business_account') {
      return WebhookNotificationType.unknown;
    }
    
    if (!payload.containsKey('entry')) {
      return WebhookNotificationType.unknown;
    }
    
    final entryList = payload['entry'];
    if (!(entryList is List) || entryList.isEmpty) {
      return WebhookNotificationType.unknown;
    }
    
    final entry = entryList[0] as Map<String, dynamic>;
    
    if (!entry.containsKey('changes')) {
      return WebhookNotificationType.unknown;
    }
    
    final changesList = entry['changes'];
    if (!(changesList is List) || changesList.isEmpty) {
      return WebhookNotificationType.unknown;
    }
    
    final changes = changesList[0] as Map<String, dynamic>;
    
    if (!changes.containsKey('value')) {
      return WebhookNotificationType.unknown;
    }
    
    final value = changes['value'] as Map<String, dynamic>;
    
    // Check for message notification
    if (value.containsKey('messages')) {
      final messages = value['messages'];
      if (messages is List && messages.isNotEmpty) {
        return WebhookNotificationType.message;
      }
    }
    
    // Check for status notification
    if (value.containsKey('statuses')) {
      final statuses = value['statuses'];
      if (statuses is List && statuses.isNotEmpty) {
        return WebhookNotificationType.status;
      }
    }
    
    return WebhookNotificationType.unknown;
  } catch (e) {
    _logger.error('Error determining webhook notification type', e);
    return WebhookNotificationType.unknown;
  }
}


  /// Processes a message event and notifies handlers.
  void _processMessageEvent(Map<String, dynamic> payload) {
    try {
      final event = MessageEvent.fromJson(payload);
      
      _logger.info('Received message event: ${event.messageType} from ${event.from}');
      
      for (final handler in _messageHandlers) {
        try {
          handler(event);
        } catch (e) {
          _logger.error('Error in message handler', e);
        }
      }
    } catch (e) {
      _logger.error('Error processing message event', e);
    }
  }

  /// Processes a status event and notifies handlers.
  void _processStatusEvent(Map<String, dynamic> payload) {
    try {
      final event = StatusEvent.fromJson(payload);
      
      _logger.info('Received status event: ${event.status} for message ${event.messageId}');
      
      for (final handler in _statusHandlers) {
        try {
          handler(event);
        } catch (e) {
          _logger.error('Error in status handler', e);
        }
      }
    } catch (e) {
      _logger.error('Error processing status event', e);
    }
  }

  /// Validates a webhook verification request.
  ///
  /// [query] is the query parameters from the request.
  /// [verifyToken] is your verification token configured in the WhatsApp Business Platform.
  /// Returns the hub.challenge value if valid, null otherwise.
  String? validateWebhook(Map<String, String> query, String verifyToken) {
    _logger.info('Validating webhook');
    
    final mode = query['hub.mode'];
    final token = query['hub.verify_token'];
    final challenge = query['hub.challenge'];
    
    if (mode == 'subscribe' && token == verifyToken && challenge != null) {
      _logger.info('Webhook verified');
      return challenge;
    }
    
    _logger.warning('Webhook verification failed');
    return null;
  }
}