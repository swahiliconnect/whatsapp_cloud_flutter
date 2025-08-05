# Practical Webhook Implementation with WhatsApp Cloud Flutter

## 🌐 Real-World Integration Example

Here's how to implement a complete webhook system using your `whatsapp_cloud_flutter` package:

## 1. 📡 Backend Webhook Server

Create a webhook server to receive WhatsApp events:

```dart
// webhook_server.dart
import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

class WhatsAppWebhookServer {
  final WhatsAppCloudClient whatsapp;
  final String verifyToken;
  
  WhatsAppWebhookServer({
    required this.whatsapp,
    required this.verifyToken,
  });

  /// Start the webhook server
  Future<void> start({String host = '0.0.0.0', int port = 8080}) async {
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler(_handleRequest);

    final server = await serve(handler, host, port);
    print('🚀 Webhook server running on ${server.address.host}:${server.port}');
    
    _setupWebhookHandlers();
  }

  /// Handle incoming HTTP requests
  Future<Response> _handleRequest(Request request) async {
    try {
      if (request.method == 'GET') {
        return _handleVerification(request);
      } else if (request.method == 'POST' && request.url.path == 'webhook') {
        return await _handleWebhookEvent(request);
      }
      
      return Response.notFound('Endpoint not found');
    } catch (e) {
      print('❌ Error handling request: $e');
      return Response.internalServerError(body: 'Internal server error');
    }
  }

  /// Handle webhook verification (required by Meta)
  Response _handleVerification(Request request) {
    final params = request.url.queryParameters;
    final mode = params['hub.mode'];
    final token = params['hub.verify_token'];
    final challenge = params['hub.challenge'];

    print('🔍 Webhook verification attempt:');
    print('  Mode: $mode');
    print('  Token: $token');
    print('  Challenge: $challenge');

    if (mode == 'subscribe' && token == verifyToken) {
      print('✅ Webhook verification successful!');
      return Response.ok(challenge);
    }

    print('❌ Webhook verification failed!');
    return Response.forbidden('Verification failed');
  }

  /// Handle incoming webhook events
  Future<Response> _handleWebhookEvent(Request request) async {
    try {
      final body = await request.readAsString();
      print('📨 Received webhook payload: $body');

      // Verify signature (recommended for production)
      if (!_verifySignature(request, body)) {
        return Response.forbidden('Invalid signature');
      }

      // Process the webhook payload
      whatsapp.webhookService.processWebhook(body);
      
      return Response.ok('EVENT_RECEIVED');
    } catch (e) {
      print('❌ Error processing webhook: $e');
      return Response.internalServerError();
    }
  }

  /// Verify webhook signature (production security)
  bool _verifySignature(Request request, String body) {
    // For development, you might skip this
    // In production, implement signature verification
    final signature = request.headers['x-hub-signature-256'];
    if (signature == null) {
      print('⚠️ No signature found in request');
      return true; // Allow for development
    }
    
    // TODO: Implement actual signature verification
    // using your webhook secret from Meta Developer Console
    return true;
  }

  /// Set up webhook event handlers
  void _setupWebhookHandlers() {
    print('🔧 Setting up webhook handlers...');

    // Handle incoming messages
    whatsapp.webhookService.registerMessageHandler((messageEvent) async {
      print('📨 New message received:');
      print('  From: ${messageEvent.from}');
      print('  Message: ${messageEvent.text}');
      print('  Type: ${messageEvent.messageType}');
      
      await _handleIncomingMessage(messageEvent);
    });

    // Handle message status updates
    whatsapp.webhookService.registerStatusHandler((statusEvent) {
      print('📊 Message status update:');
      print('  Message ID: ${statusEvent.messageId}');
      print('  Status: ${statusEvent.status}');
      print('  Recipient: ${statusEvent.recipientId}');
      
      _handleStatusUpdate(statusEvent);
    });

    // Handle interactive message responses (buttons, lists)
    whatsapp.webhookService.registerInteractiveHandler((interactiveEvent) async {
      print('🎯 Interactive response received:');
      print('  From: ${interactiveEvent.from}');
      print('  Button ID: ${interactiveEvent.buttonId}');
      print('  Title: ${interactiveEvent.buttonTitle}');
      
      await _handleInteractiveResponse(interactiveEvent);
    });

    print('✅ Webhook handlers configured successfully!');
  }

  /// Handle incoming messages with auto-replies
  Future<void> _handleIncomingMessage(MessageEvent event) async {
    final userMessage = event.text?.toLowerCase() ?? '';
    
    try {
      // Simple auto-reply logic
      String? replyMessage;
      
      if (userMessage.contains('hello') || userMessage.contains('hi')) {
        replyMessage = '👋 Hello! How can I help you today?';
      } else if (userMessage.contains('help')) {
        replyMessage = '''
🤖 I can help you with:
• Product information
• Support tickets
• Order status
• General questions

Just type what you need!
        ''';
      } else if (userMessage.contains('price') || userMessage.contains('cost')) {
        replyMessage = '💰 Let me get you pricing information. What product are you interested in?';
      } else if (userMessage.contains('bye') || userMessage.contains('goodbye')) {
        replyMessage = '👋 Goodbye! Have a great day!';
      } else {
        replyMessage = '🤔 I received your message: "$userMessage"\n\nI\'m a demo bot. Type "help" for available commands.';
      }
      
      if (replyMessage != null) {
        final response = await whatsapp.messageService.sendTextMessage(
          recipient: event.from,
          text: replyMessage,
        );
        
        if (response.successful) {
          print('✅ Auto-reply sent successfully');
        } else {
          print('❌ Failed to send auto-reply: ${response.errorMessage}');
        }
      }
    } catch (e) {
      print('❌ Error in auto-reply: $e');
    }
  }

  /// Handle message status updates
  void _handleStatusUpdate(StatusEvent event) {
    // You can update your database or notify your Flutter app
    switch (event.status.toLowerCase()) {
      case 'sent':
        print('📤 Message sent to WhatsApp servers');
        break;
      case 'delivered':
        print('📬 Message delivered to recipient');
        break;
      case 'read':
        print('👀 Message read by recipient');
        break;
      case 'failed':
        print('❌ Message delivery failed');
        break;
    }
  }

  /// Handle interactive responses (button clicks, list selections)
  Future<void> _handleInteractiveResponse(InteractiveEvent event) async {
    final buttonId = event.buttonId;
    
    try {
      String replyMessage = '';
      
      switch (buttonId) {
        case 'get_support':
          replyMessage = '🎧 I\'ve connected you with our support team. They\'ll be with you shortly!';
          break;
        case 'view_products':
          replyMessage = '🛍️ Here are our featured products:\n• Product A - \$99\n• Product B - \$149\n• Product C - \$199';
          break;
        case 'track_order':
          replyMessage = '📦 Please provide your order number and I\'ll check the status for you.';
          break;
        default:
          replyMessage = '✅ Got it! You selected: ${event.buttonTitle}';
      }
      
      final response = await whatsapp.messageService.sendTextMessage(
        recipient: event.from,
        text: replyMessage,
      );
      
      if (response.successful) {
        print('✅ Interactive response sent successfully');
      } else {
        print('❌ Failed to send interactive response: ${response.errorMessage}');
      }
    } catch (e) {
      print('❌ Error handling interactive response: $e');
    }
  }

  /// CORS middleware for web requests
  Middleware _corsMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        final response = await handler(request);
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        });
      };
    };
  }
}

/// Main function to start the webhook server
Future<void> main() async {
  // Initialize WhatsApp client
  final whatsapp = WhatsAppCloudClient(
    phoneNumberId: Platform.environment['PHONE_NUMBER_ID'] ?? 'YOUR_PHONE_NUMBER_ID',
    accessToken: Platform.environment['ACCESS_TOKEN'] ?? 'YOUR_ACCESS_TOKEN',
    config: WhatsAppApiConfig(
      logLevel: LogLevel.debug,
      environment: Environment.production,
    ),
  );

  // Create and start webhook server
  final webhookServer = WhatsAppWebhookServer(
    whatsapp: whatsapp,
    verifyToken: Platform.environment['VERIFY_TOKEN'] ?? 'YOUR_VERIFY_TOKEN',
  );

  await webhookServer.start(
    host: '0.0.0.0',
    port: int.parse(Platform.environment['PORT'] ?? '8080'),
  );
}
```

## 2. 📱 Flutter App Integration

Connect your Flutter app with the webhook system:

```dart
// lib/services/whatsapp_chat_service.dart
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

class WhatsAppChatService {
  late WhatsAppCloudClient _whatsapp;
  final List<ChatMessage> _messages = [];
  
  // Stream for real-time updates
  final StreamController<List<ChatMessage>> _messagesController = 
      StreamController<List<ChatMessage>>.broadcast();
  
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void initialize() {
    _whatsapp = WhatsAppCloudClient(
      phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
      accessToken: 'YOUR_ACCESS_TOKEN',
    );

    print('✅ WhatsApp service initialized');
  }

  /// Send a message to WhatsApp
  Future<bool> sendMessage(String recipient, String text) async {
    try {
      // Add message to local list immediately (optimistic update)
      final localMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        sender: 'me',
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
      );
      
      _messages.add(localMessage);
      _messagesController.add(_messages);

      // Send via WhatsApp API
      final response = await _whatsapp.messageService.sendTextMessage(
        recipient: recipient,
        text: text,
        previewUrl: true,
      );

      if (response.successful) {
        // Update message status
        final index = _messages.indexWhere((m) => m.id == localMessage.id);
        if (index != -1) {
          _messages[index] = localMessage.copyWith(
            id: response.messageId ?? localMessage.id,
            status: MessageStatus.sent,
          );
          _messagesController.add(_messages);
        }
        
        print('✅ Message sent: ${response.messageId}');
        return true;
      } else {
        // Update message status to failed
        final index = _messages.indexWhere((m) => m.id == localMessage.id);
        if (index != -1) {
          _messages[index] = localMessage.copyWith(
            status: MessageStatus.failed,
          );
          _messagesController.add(_messages);
        }
        
        print('❌ Failed to send message: ${response.errorMessage}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      return false;
    }
  }

  /// Send an interactive message with buttons
  Future<bool> sendInteractiveMessage(String recipient) async {
    try {
      final message = InteractiveMessage(
        recipient: recipient,
        interactiveType: InteractiveType.button,
        body: BodyComponent(text: 'How can we help you today?'),
        action: ActionComponent(
          buttons: [
            ButtonComponent(id: 'get_support', title: '🎧 Get Support'),
            ButtonComponent(id: 'view_products', title: '🛍️ View Products'),
            ButtonComponent(id: 'track_order', title: '📦 Track Order'),
          ],
        ),
      );

      final response = await _whatsapp.messageService.sendMessage(message);
      
      if (response.successful) {
        print('✅ Interactive message sent');
        return true;
      } else {
        print('❌ Failed to send interactive message: ${response.errorMessage}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending interactive message: $e');
      return false;
    }
  }

  /// Handle incoming messages from webhook
  /// (This would be called by your backend via WebSocket or polling)
  void handleIncomingMessage(Map<String, dynamic> messageData) {
    final message = ChatMessage.fromWebhook(messageData);
    _messages.add(message);
    _messagesController.add(_messages);
    
    print('📨 Received message: ${message.text}');
  }

  /// Update message status from webhook
  void updateMessageStatus(String messageId, String status) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(
        status: _parseMessageStatus(status),
      );
      _messagesController.add(_messages);
      
      print('📊 Message $messageId status updated to $status');
    }
  }

  MessageStatus _parseMessageStatus(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  void dispose() {
    _messagesController.close();
  }
}

// Data models
class ChatMessage {
  final String id;
  final String text;
  final String sender; // 'me' or phone number
  final DateTime timestamp;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.status,
  });

  factory ChatMessage.fromWebhook(Map<String, dynamic> data) {
    return ChatMessage(
      id: data['id'] ?? '',
      text: data['text'] ?? '',
      sender: data['from'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.parse(data['timestamp'] ?? '0') * 1000,
      ),
      status: MessageStatus.received,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? text,
    String? sender,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
  received,
}
```

## 3. 🚀 Deployment Guide

### Option A: Local Development with ngrok

```bash
# 1. Start your webhook server
dart run webhook_server.dart

# 2. In another terminal, expose it with ngrok
ngrok http 8080

# 3. Use the ngrok URL in Meta Developer Console
# Example: https://abc123.ngrok.io/webhook
```

### Option B: Deploy to Cloud

```yaml
# docker-compose.yml
version: '3.8'
services:
  whatsapp-webhook:
    build: .
    ports:
      - "8080:8080"
    environment:
      - PHONE_NUMBER_ID=your_phone_number_id
      - ACCESS_TOKEN=your_access_token
      - VERIFY_TOKEN=your_verify_token
      - PORT=8080
    restart: unless-stopped
```

```dockerfile
# Dockerfile
FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart compile exe webhook_server.dart -o webhook_server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/webhook_server /app/
EXPOSE 8080
ENTRYPOINT ["/app/webhook_server"]
```

## 4. 🔧 Meta Developer Console Setup

### Step 1: Configure Webhook URL
```
Webhook URL: https://your-domain.com/webhook
Verify Token: your_verify_token_here
```

### Step 2: Subscribe to Events
- ✅ `messages` - Incoming messages
- ✅ `message_deliveries` - Delivery confirmations  
- ✅ `message_reads` - Read receipts
- ✅ `message_reactions` - Message reactions

### Step 3: Test the Setup
1. Send a test message from your Flutter app
2. Check webhook server logs for delivery status
3. Reply to your business number from WhatsApp
4. Verify your webhook receives the message

## 🔍 Testing & Debugging

```dart
// Add to your webhook server for detailed logging
void logWebhookEvent(String eventType, Map<String, dynamic> data) {
  print('🔍 Webhook Event: $eventType');
  print('📋 Data: ${JsonEncoder.withIndent('  ').convert(data)}');
  print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
  print('─' * 50);
}
```

This complete setup gives you real-time, bidirectional communication between your Flutter app and WhatsApp users! 🚀
