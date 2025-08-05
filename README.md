# WhatsApp Cloud Flutter

[![pub package](https://img.shields.io/pub/v/whatsapp_cloud_flutter.svg)](https://pub.dev/packages/whatsapp_cloud_flutter)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/swahiliconnect/whatsapp_cloud_flutter/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/swahiliconnect/whatsapp_cloud_flutter.svg)](https://github.com/swahiliconnect/whatsapp_cloud_flutter/stargazers)

A comprehensive Flutter package that provides a type-safe, easy-to-use wrapper around Meta's WhatsApp Cloud API. This package enables Flutter developers to integrate WhatsApp messaging capabilities into their applications with minimal effort, handling the complexities of API interactions, authentication, and message formatting.

**Developed by [Israel Biselu](https://github.com/israelbiselu) from [SwahiliConnect](https://github.com/swahiliconnect)**

## 🌟 Why Choose WhatsApp Cloud Flutter?

- **🚀 Production Ready**: Built with enterprise-grade reliability and scalability
- **🛡️ Type Safe**: Full TypeScript-like type safety for all API interactions
- **📱 Flutter Native**: Designed specifically for Flutter with native widget support
- **🔧 Easy Integration**: Get started in minutes with minimal configuration
- **📚 Comprehensive**: Covers all WhatsApp Cloud API features and message types
- **🔐 Secure**: Built-in security features including webhook verification
- **⚡ Performance**: Optimized with rate limiting, retry mechanisms, and efficient networking

## 🚀 Features

### 📱 Complete Message Support
- **Text Messages** - Rich text with URL previews and formatting
- **Media Messages** - Images, videos, audio, documents, and stickers
- **Interactive Messages** - Buttons, lists, and call-to-action components
- **Advanced Interactive** - CTA URLs, location requests, address collection
- **Location Messages** - GPS coordinates with names and addresses
- **Contact Cards** - vCard format contact sharing
- **Template Messages** - Business templates with dynamic content
- **Reaction Messages** - Emoji reactions to messages

### �️ Developer Experience
- **🔧 Simple Setup** - Initialize in 3 lines of code
- **📋 Template Management** - Create, retrieve, and send templates
- **📁 Media Handling** - Upload, download, and manage media files
- **🔔 Webhook Integration** - Real-time message and status updates
- **📊 Analytics & Monitoring** - Built-in metrics and performance tracking
- **🪵 Comprehensive Logging** - Debug-friendly logging at multiple levels

### 🔒 Enterprise Features
- **⚡ Rate Limiting** - Automatic API quota management
- **🔄 Retry Logic** - Exponential backoff for failed requests
- **🛡️ Security** - Webhook signature verification and token management
- **📈 Scalability** - Designed for high-volume messaging scenarios
- **🎯 Error Handling** - Detailed error types and recovery strategies

### 🎨 UI Components (Bonus!)
- **MessageComposer** - Ready-to-use message input widget
- **TemplateSelector** - Template picker with preview
- **ChatBubble** - Customizable message bubbles
- **MediaPicker** - Integrated media selection

## 📦 Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  whatsapp_cloud_flutter: ^1.0.0
```

Install it:

```bash
flutter pub get
```

Import it:

```dart
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';
```

## 🏁 Quick Start

### Step 1: Get Your Credentials

Before using this package, you need:

1. **Meta Developer Account** - [Create one here](https://developers.facebook.com/)
2. **WhatsApp Business Account** - Set up in Meta Business Manager
3. **WhatsApp Business App** - Create in Meta Developers Console
4. **Phone Number ID** - Found in your app settings
5. **Access Token** - Generate in Meta Developers Console

> 💡 **Pro Tip**: Start with a [temporary access token](https://developers.facebook.com/docs/whatsapp/cloud-api/get-started#temporary-access-token) for testing, then implement [permanent tokens](https://developers.facebook.com/docs/whatsapp/cloud-api/get-started#permanent-access-token) for production.

### Step 2: Initialize the Client

```dart
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

// Basic initialization
final whatsapp = WhatsAppCloudClient(
  phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
  accessToken: 'YOUR_ACCESS_TOKEN',
);

// Advanced initialization with custom configuration
final whatsapp = WhatsAppCloudClient(
  phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
  accessToken: 'YOUR_ACCESS_TOKEN',
  config: WhatsAppApiConfig(
    logLevel: LogLevel.debug,
    environment: Environment.production,
    retryPolicy: RetryPolicy(maxRetries: 3),
    connectTimeout: Duration(seconds: 30),
  ),
);
```

### Step 3: Send Your First Message

```dart
try {
  final response = await whatsapp.messageService.sendTextMessage(
    recipient: '+1234567890', // Include country code
    text: 'Hello from Flutter! 🚀',
    previewUrl: true,
  );

  if (response.successful) {
    print('✅ Message sent! ID: ${response.messageId}');
  } else {
    print('❌ Failed: ${response.errorMessage}');
  }
} catch (e) {
  print('🚨 Error: $e');
}
```

That's it! You've sent your first WhatsApp message from Flutter! 🎉

## 📚 Comprehensive Usage Guide

### 💬 Text Messages

```dart
// Simple text message
await whatsapp.messageService.sendTextMessage(
  recipient: '+1234567890',
  text: 'Hello World!',
);

// Text with URL preview
await whatsapp.messageService.sendTextMessage(
  recipient: '+1234567890',
  text: 'Check out this amazing Flutter package: https://pub.dev/packages/whatsapp_cloud_flutter',
  previewUrl: true,
);

// Formatted text (WhatsApp formatting)
await whatsapp.messageService.sendTextMessage(
  recipient: '+1234567890',
  text: '*Bold text* _italic text_ ~strikethrough~ ```monospace```',
);
```

### 🖼️ Media Messages

```dart
// Send image from URL
await whatsapp.messageService.sendImageMessage(
  recipient: '+1234567890',
  source: MediaSource.url,
  mediaUrl: 'https://example.com/image.jpg',
  caption: 'Beautiful sunset! 🌅',
);

// Send image from local file
final file = File('path/to/local/image.jpg');
final uploadResponse = await whatsapp.mediaService.uploadMedia(
  mediaType: MediaType.image,
  file: file,
);

if (uploadResponse.successful) {
  await whatsapp.messageService.sendImageMessage(
    recipient: '+1234567890',
    source: MediaSource.id,
    mediaId: uploadResponse.mediaId!,
    caption: 'Image from my phone!',
  );
}

// Send document
await whatsapp.messageService.sendDocumentMessage(
  recipient: '+1234567890',
  source: MediaSource.url,
  mediaUrl: 'https://example.com/document.pdf',
  filename: 'important_document.pdf',
  caption: 'Please review this document',
);

// Send video
await whatsapp.messageService.sendVideoMessage(
  recipient: '+1234567890',
  source: MediaSource.url,
  mediaUrl: 'https://example.com/video.mp4',
  caption: 'Product demo video',
);

// Send audio
await whatsapp.messageService.sendAudioMessage(
  recipient: '+1234567890',
  source: MediaSource.url,
  mediaUrl: 'https://example.com/audio.mp3',
);
```

### 🗺️ Location Messages

```dart
// Send location
await whatsapp.messageService.sendLocationMessage(
  recipient: '+1234567890',
  latitude: 37.7749,
  longitude: -122.4194,
  name: 'San Francisco Office',
  address: '123 Market St, San Francisco, CA 94103',
);
```

### 📇 Contact Messages

```dart
// Send contact card
await whatsapp.messageService.sendContactMessage(
  recipient: '+1234567890',
  contacts: [
    Contact(
      name: ContactName(
        formattedName: 'John Doe',
        firstName: 'John',
        lastName: 'Doe',
      ),
      phones: [
        ContactPhone(
          phone: '+1234567890',
          type: 'WORK',
        ),
      ],
      emails: [
        ContactEmail(
          email: 'john.doe@company.com',
          type: 'WORK',
        ),
      ],
    ),
  ],
);
```

### 📋 Template Messages

```dart
// Send a simple template
await whatsapp.templateService.sendTemplate(
  recipient: '+1234567890',
  templateName: 'hello_world',
  language: 'en_US',
);

// Send template with parameters
await whatsapp.templateService.sendTemplate(
  recipient: '+1234567890',
  templateName: 'appointment_reminder',
  language: 'en_US',
  components: [
    TemplateComponent(
      type: ComponentType.body,
      parameters: [
        TextParameter(text: 'John Doe'),
        DateTimeParameter(datetime: DateTime.now().add(Duration(days: 2))),
      ],
    ),
    TemplateComponent(
      type: ComponentType.button,
      subType: 'quick_reply',
      index: 0,
      parameters: [
        TextParameter(text: 'Confirm'),
      ],
    ),
  ],
);

// Get available templates
final templates = await whatsapp.templateService.getTemplates();
for (final template in templates) {
  print('Template: ${template.name} - Status: ${template.status}');
}
```

### 🎯 Interactive Messages

```dart
// Send button message
final buttonMessage = InteractiveMessage(
  recipient: '+1234567890',
  interactiveType: InteractiveType.button,
  body: BodyComponent(text: 'Choose your preferred option:'),
  action: ActionComponent(
    buttons: [
      ButtonComponent(id: 'option_1', title: 'Option 1'),
      ButtonComponent(id: 'option_2', title: 'Option 2'),
      ButtonComponent(id: 'option_3', title: 'Option 3'),
    ],
  ),
);

await whatsapp.messageService.sendMessage(buttonMessage);

// Send list message
final listMessage = InteractiveMessage(
  recipient: '+1234567890',
  interactiveType: InteractiveType.list,
  body: BodyComponent(text: 'Select from our menu:'),
  action: ActionComponent(
    buttonText: 'View Menu',
    sections: [
      ListSection(
        title: 'Main Courses',
        rows: [
          ListRow(id: 'pasta', title: 'Pasta', description: 'Delicious Italian pasta'),
          ListRow(id: 'pizza', title: 'Pizza', description: 'Wood-fired pizza'),
        ],
      ),
      ListSection(
        title: 'Desserts',
        rows: [
          ListRow(id: 'tiramisu', title: 'Tiramisu', description: 'Classic Italian dessert'),
        ],
      ),
    ],
  ),
);

await whatsapp.messageService.sendMessage(listMessage);
```

### 📊 Message Status Tracking

```dart
// Mark message as read
await whatsapp.messageService.markMessageAsRead(
  messageId: 'wamid.HBgNMTc3...',
);

// Send reaction to a message
await whatsapp.messageService.sendReaction(
  recipient: '+1234567890',
  messageId: 'wamid.HBgNMTc3...',
  emoji: '👍',
);

// Remove reaction
await whatsapp.messageService.sendReaction(
  recipient: '+1234567890',
  messageId: 'wamid.HBgNMTc3...',
  emoji: '', // Empty string removes reaction
);
```

### 📁 Media Management

```dart
// Upload media from file
final file = File('path/to/image.jpg');
final uploadResponse = await whatsapp.mediaService.uploadMedia(
  mediaType: MediaType.image,
  file: file,
);

if (uploadResponse.successful) {
  print('Media uploaded! ID: ${uploadResponse.mediaId}');
  
  // Use the media ID to send messages
  await whatsapp.messageService.sendImageMessage(
    recipient: '+1234567890',
    source: MediaSource.id,
    mediaId: uploadResponse.mediaId!,
    caption: 'Uploaded image',
  );
}

// Download media
final downloadResponse = await whatsapp.mediaService.downloadMedia(
  mediaId: 'MEDIA_ID_HERE',
);

if (downloadResponse.successful) {
  final mediaBytes = downloadResponse.data;
  // Save to file or display in your app
}

// Get media info
final mediaInfo = await whatsapp.mediaService.getMediaInfo('MEDIA_ID_HERE');
print('Media size: ${mediaInfo.fileSize} bytes');
print('Media type: ${mediaInfo.mimeType}');
```

### 🔔 Webhook Integration

Set up webhooks to receive real-time updates:

```dart
// Register message handler
whatsapp.webhookService.registerMessageHandler((messageEvent) {
  print('📨 New message from ${messageEvent.from}: ${messageEvent.text}');
  
  // Auto-reply example
  if (messageEvent.text?.toLowerCase() == 'hello') {
    whatsapp.messageService.sendTextMessage(
      recipient: messageEvent.from,
      text: 'Hi there! How can I help you today?',
    );
  }
});

// Register status update handler
whatsapp.webhookService.registerStatusHandler((statusEvent) {
  print('📊 Message ${statusEvent.messageId} status: ${statusEvent.status}');
  
  switch (statusEvent.status) {
    case MessageStatus.delivered:
      print('✅ Message delivered');
      break;
    case MessageStatus.read:
      print('👀 Message read');
      break;
    case MessageStatus.failed:
      print('❌ Message failed: ${statusEvent.error}');
      break;
  }
});

// Register interactive message handler
whatsapp.webhookService.registerInteractiveHandler((interactiveEvent) {
  print('🎯 Button clicked: ${interactiveEvent.buttonId}');
  
  // Handle button responses
  switch (interactiveEvent.buttonId) {
    case 'confirm':
      whatsapp.messageService.sendTextMessage(
        recipient: interactiveEvent.from,
        text: 'Great! Your booking is confirmed.',
      );
      break;
    case 'cancel':
      whatsapp.messageService.sendTextMessage(
        recipient: interactiveEvent.from,
        text: 'No problem! Let me know if you need anything else.',
      );
      break;
  }
});

// Process incoming webhook (in your web server)
app.post('/webhook', (req, res) {
  final payload = req.body;
  whatsapp.webhookService.processWebhook(payload);
  res.status(200).send('OK');
});

// Webhook verification (required by Meta)
app.get('/webhook', (req, res) {
  final mode = req.query['hub.mode'];
  final token = req.query['hub.verify_token'];
  final challenge = req.query['hub.challenge'];
  
  final result = whatsapp.webhookService.verifyWebhook(
    mode: mode,
    verifyToken: token,
    challenge: challenge,
    expectedToken: 'YOUR_VERIFY_TOKEN',
  );
  
  res.send(result);
});
```

### 🎨 Flutter UI Components

This package includes ready-to-use Flutter widgets to speed up your development:

```dart
import 'package:flutter/material.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

class ChatScreen extends StatelessWidget {
  final WhatsAppCloudClient whatsapp;
  final String recipient;

  const ChatScreen({required this.whatsapp, required this.recipient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WhatsApp Chat')),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView(
              children: [
                ChatBubble(
                  message: 'Hello! How can I help you?',
                  alignment: BubbleAlignment.left,
                  timestamp: DateTime.now(),
                  senderName: 'Support',
                ),
                ChatBubble(
                  message: 'I need help with my order',
                  alignment: BubbleAlignment.right,
                  timestamp: DateTime.now(),
                ),
              ],
            ),
          ),
          
          // Message composer
          MessageComposer(
            messageService: whatsapp.messageService,
            recipient: recipient,
            placeholder: 'Type your message...',
            onMessageSent: (messageId) {
              print('Message sent: $messageId');
              // Update your UI
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $error')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Template selector widget
class TemplateScreen extends StatelessWidget {
  final WhatsAppCloudClient whatsapp;
  final String recipient;

  const TemplateScreen({required this.whatsapp, required this.recipient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose Template')),
      body: TemplateSelector(
        templateService: whatsapp.templateService,
        recipient: recipient,
        languageCode: 'en_US',
        onTemplateSent: (messageId) {
          Navigator.pop(context);
          print('Template sent: $messageId');
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      ),
    );
  }
}
```

## 🚨 Error Handling

The package provides comprehensive error handling with specific exception types:

```dart
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

try {
  final response = await whatsapp.messageService.sendTextMessage(
    recipient: '+1234567890',
    text: 'Hello World!',
  );
  
  if (response.successful) {
    print('✅ Success: ${response.messageId}');
  } else {
    print('❌ API Error: ${response.errorMessage}');
  }
  
} on AuthException catch (e) {
  // Authentication/authorization errors
  print('🔐 Auth Error: ${e.message}');
  // Refresh token or re-authenticate
  
} on RateLimitException catch (e) {
  // Rate limiting errors
  print('⏱️ Rate Limited: Retry after ${e.retryAfter} seconds');
  // Implement backoff strategy
  
} on MediaException catch (e) {
  // Media-specific errors (file too large, invalid format, etc.)
  print('📁 Media Error: ${e.code} - ${e.message}');
  // Handle media-specific issues
  
} on MessageException catch (e) {
  // Message-specific errors (invalid recipient, content issues, etc.)
  print('💬 Message Error: ${e.code} - ${e.message}');
  // Handle message validation issues
  
} on ApiException catch (e) {
  // General API errors
  print('🌐 API Error: ${e.statusCode} - ${e.message}');
  // Handle network/server issues
  
} on ValidationException catch (e) {
  // Input validation errors
  print('✅ Validation Error: ${e.field} - ${e.message}');
  // Handle input validation
  
} catch (e) {
  // Unexpected errors
  print('🚨 Unexpected Error: $e');
  // Handle unknown errors gracefully
}
```

### Retry Strategy Example

```dart
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

Future<MessageResponse?> sendMessageWithRetry({
  required String recipient,
  required String text,
  int maxRetries = 3,
}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      final response = await whatsapp.messageService.sendTextMessage(
        recipient: recipient,
        text: text,
      );
      
      if (response.successful) {
        return response; // Success!
      }
      
      // If this was the last attempt, return the failed response
      if (attempt == maxRetries) {
        return response;
      }
      
    } on RateLimitException catch (e) {
      if (attempt == maxRetries) rethrow;
      
      // Wait for the rate limit to reset
      await Future.delayed(Duration(seconds: e.retryAfter));
      continue;
      
    } on ApiException catch (e) {
      // For server errors (5xx), retry after a delay
      if (e.statusCode >= 500 && attempt < maxRetries) {
        await Future.delayed(Duration(seconds: attempt * 2));
        continue;
      }
      rethrow;
      
    } catch (e) {
      // For other errors, don't retry
      rethrow;
    }
  }
  
  return null;
}
```

## ⚙️ Advanced Configuration

Customize the client behavior with advanced configuration options:

```dart
final config = WhatsAppApiConfig(
  // API settings
  baseUrl: 'https://graph.facebook.com/v18.0', // API version
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  
  // Environment
  environment: Environment.production, // or Environment.sandbox
  
  // Logging
  logLevel: LogLevel.debug, // debug, info, warning, error, off
  
  // Retry policy
  retryPolicy: RetryPolicy(
    maxRetries: 3,
    initialBackoff: Duration(seconds: 1),
    maxBackoff: Duration(seconds: 30),
  ),
  
  // Rate limiting (optional - helps prevent quota issues)
  rateLimitConfig: RateLimitConfig(
    requestsPerMinute: 80,
    requestsPerHour: 1000,
    requestsPerDay: 10000,
  ),
);

final whatsapp = WhatsAppCloudClient(
  phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
  accessToken: 'YOUR_ACCESS_TOKEN',
  config: config,
);
```

### Environment-Specific Configuration

```dart
// Development environment
final devConfig = WhatsAppApiConfig(
  environment: Environment.sandbox,
  logLevel: LogLevel.debug,
  retryPolicy: RetryPolicy(maxRetries: 1), // Fail fast in dev
);

// Production environment
final prodConfig = WhatsAppApiConfig(
  environment: Environment.production,
  logLevel: LogLevel.warning, // Less verbose logging
  retryPolicy: RetryPolicy(
    maxRetries: 5,
    initialBackoff: Duration(seconds: 2),
    maxBackoff: Duration(minutes: 5),
  ),
  rateLimitConfig: RateLimitConfig.businessLimits, // Higher limits
);
```

### Security Configuration

```dart
// For webhook signature verification
final securityConfig = SecurityConfig(
  webhookSecret: 'YOUR_WEBHOOK_SECRET',
  verifySignatures: true,
  allowedOrigins: ['your-domain.com'],
);

// Initialize with security
final whatsapp = WhatsAppCloudClient(
  phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
  accessToken: 'YOUR_ACCESS_TOKEN',
  securityConfig: securityConfig,
);
```

## 📊 Analytics & Monitoring

Track your messaging performance with built-in analytics:

```dart
// Enable analytics
final analytics = WhatsAppAnalytics(
  logger: Logger(), // Your logger instance
);

// Record events automatically or manually
analytics.recordMessageSent('text', Duration(milliseconds: 150));
analytics.recordError('rate_limit', '429');

// Get performance metrics
final stats = analytics.getSummaryReport();
print('Success rate: ${stats['performance']['success_rate_percent']}%');
print('Average response time: ${stats['performance']['average_response_time_ms']}ms');

// Message type breakdown
final messageStats = analytics.messageTypeStats;
messageStats.forEach((type, count) {
  print('$type messages: $count');
});

// Error analysis
final errorStats = analytics.errorStats;
errorStats.forEach((error, count) {
  print('$error errors: $count');
});
```

## 🔐 Production Security Checklist

### ✅ Authentication & Authorization
- [ ] Use permanent access tokens (not temporary ones)
- [ ] Implement token refresh logic
- [ ] Store tokens securely (not in code/version control)
- [ ] Use environment variables or secure storage
- [ ] Implement proper user authentication in your app

### ✅ Webhook Security
- [ ] Set up webhook signature verification
- [ ] Use HTTPS for webhook URLs
- [ ] Validate webhook payloads
- [ ] Implement rate limiting on webhook endpoints
- [ ] Set up proper error handling

### ✅ Input Validation
- [ ] Validate phone numbers (international format)
- [ ] Sanitize user input before sending messages
- [ ] Validate file uploads (size, type, content)
- [ ] Implement content filtering if needed

### ✅ Error Handling
- [ ] Implement comprehensive error handling
- [ ] Set up monitoring and alerting
- [ ] Log errors securely (don't log sensitive data)
- [ ] Implement fallback mechanisms

### ✅ Rate Limiting & Performance
- [ ] Configure appropriate rate limits
- [ ] Implement message queuing for high volume
- [ ] Set up monitoring for API quotas
- [ ] Optimize media file sizes

```dart
// Example secure configuration
final secureConfig = WhatsAppApiConfig(
  environment: Environment.production,
  logLevel: LogLevel.warning, // Don't log sensitive data
  retryPolicy: RetryPolicy(
    maxRetries: 5,
    initialBackoff: Duration(seconds: 2),
  ),
  connectTimeout: Duration(seconds: 15),
  receiveTimeout: Duration(seconds: 15),
);

// Secure token management
class TokenManager {
  static Future<String> getAccessToken() async {
    // Get from secure storage, not hardcoded
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('whatsapp_token') ?? '';
  }
  
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('whatsapp_token', token);
  }
  
  static Future<void> refreshToken() async {
    // Implement token refresh logic
    // Make API call to refresh token
    // Save new token securely
  }
}
```

## 📱 Example Application

The package includes a comprehensive example app that demonstrates all features. To run it:

```bash
git clone https://github.com/swahiliconnect/whatsapp_cloud_flutter.git
cd whatsapp_cloud_flutter/example
flutter pub get
flutter run
```

The example app includes:
- **Configuration Setup** - Easy credential management
- **Text Messaging** - Send messages with URL previews
- **Location Sharing** - Send GPS coordinates
- **Media Upload** - Handle images, videos, documents
- **Template Management** - Work with business templates
- **Webhook Testing** - Test webhook functionality
- **Error Handling** - See how errors are handled
- **Real-time Logging** - Monitor API interactions

### Example App Screenshots

| Configuration | Messaging | Templates |
|:-------------:|:---------:|:---------:|
| ![Config](https://github.com/swahiliconnect/whatsapp_cloud_flutter/raw/main/screenshots/config.png) | ![Messages](https://github.com/swahiliconnect/whatsapp_cloud_flutter/raw/main/screenshots/messages.png) | ![Templates](https://github.com/swahiliconnect/whatsapp_cloud_flutter/raw/main/screenshots/templates.png) |

## 🛠️ Development & Testing

### Testing Your Integration

1. **Use WhatsApp Test Numbers**: Start with Meta's test phone numbers
2. **Verify Webhook Setup**: Use tools like ngrok for local testing
3. **Test Error Scenarios**: Simulate rate limits, invalid tokens, etc.
4. **Monitor API Usage**: Keep track of your quotas and limits

### Debugging Tips

```dart
// Enable debug logging
final whatsapp = WhatsAppCloudClient(
  phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
  accessToken: 'YOUR_ACCESS_TOKEN',
  config: WhatsAppApiConfig(
    logLevel: LogLevel.debug, // See all API calls
  ),
);

// Test API connectivity
try {
  final response = await whatsapp.messageService.sendTextMessage(
    recipient: 'YOUR_TEST_NUMBER',
    text: 'Test message',
  );
  print('API is working: ${response.successful}');
} catch (e) {
  print('API issue: $e');
}
```

### Unit Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

// Mock the client for testing
class MockWhatsAppClient extends Mock implements WhatsAppCloudClient {}

void main() {
  group('WhatsApp Integration Tests', () {
    late MockWhatsAppClient mockClient;

    setUp(() {
      mockClient = MockWhatsAppClient();
    });

    test('should send text message successfully', () async {
      // Arrange
      const recipient = '+1234567890';
      const text = 'Test message';
      final expectedResponse = MessageResponse(
        successful: true,
        messageId: 'test-id-123',
      );

      when(mockClient.messageService.sendTextMessage(
        recipient: recipient,
        text: text,
      )).thenAnswer((_) async => expectedResponse);

      // Act
      final response = await mockClient.messageService.sendTextMessage(
        recipient: recipient,
        text: text,
      );

      // Assert
      expect(response.successful, true);
      expect(response.messageId, 'test-id-123');
    });
  });
}
```

## 🌐 API Reference & Documentation

### Complete API Documentation
- **[pub.dev Documentation](https://pub.dev/documentation/whatsapp_cloud_flutter/latest/)** - Complete API reference
- **[WhatsApp Cloud API Docs](https://developers.facebook.com/docs/whatsapp/cloud-api/)** - Official Meta documentation
- **[GitHub Wiki](https://github.com/swahiliconnect/whatsapp_cloud_flutter/wiki)** - Detailed guides and tutorials

### Supported WhatsApp Cloud API Version
This package supports **WhatsApp Cloud API v18.0** and is backward compatible with v16.0+.

### Rate Limits & Quotas
- **Free Tier**: 1,000 conversations/month
- **Business Tier**: Pay-per-conversation pricing
- **API Limits**: 80 messages/minute, 1,000 messages/hour
- **Media Limits**: 100MB file size, specific formats supported

## 🤝 Contributing

We welcome contributions! This is an open-source project maintained by **SwahiliConnect**.

### How to Contribute

1. **Fork the Project** - Click the fork button on GitHub
2. **Create Feature Branch** - `git checkout -b feature/AmazingFeature`
3. **Write Tests** - Ensure your code is tested
4. **Commit Changes** - `git commit -m 'Add some AmazingFeature'`
5. **Push to Branch** - `git push origin feature/AmazingFeature`
6. **Open Pull Request** - Submit your changes for review

### Development Setup

```bash
# Clone the repository
git clone https://github.com/swahiliconnect/whatsapp_cloud_flutter.git
cd whatsapp_cloud_flutter

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run example app
cd example
flutter pub get
flutter run
```

### Contribution Guidelines

- ✅ Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- ✅ Write comprehensive tests for new features
- ✅ Update documentation for API changes
- ✅ Ensure backward compatibility when possible
- ✅ Add examples for new features

## 🎯 Roadmap & Future Plans

### Upcoming Features
- **🎨 Enhanced UI Components** - More customizable widgets
- **📊 Advanced Analytics** - Detailed reporting and insights
- **🔄 Message Sync** - Two-way message synchronization
- **🤖 Bot Framework** - Built-in chatbot capabilities
- **📦 Message Templates** - Visual template builder
- **🌍 Multi-language Support** - Localization helpers

### Community Requests
Vote for features on our [GitHub Discussions](https://github.com/swahiliconnect/whatsapp_cloud_flutter/discussions)!

## ❓ FAQ

<details>
<summary><strong>How do I get WhatsApp Cloud API access?</strong></summary>

1. Create a [Meta Developer account](https://developers.facebook.com/)
2. Set up a [WhatsApp Business account](https://business.whatsapp.com/)
3. Create a WhatsApp Business App in Meta Developers Console
4. Get your Phone Number ID and Access Token
5. Set up webhook endpoints (optional but recommended)

</details>

<details>
<summary><strong>Is this package free to use?</strong></summary>

Yes! This package is completely free and open-source (MIT License). However, WhatsApp Cloud API has its own pricing:
- **Free**: 1,000 conversations per month
- **Paid**: Pay-per-conversation after free tier

</details>

<details>
<summary><strong>Can I use this in production?</strong></summary>

Absolutely! This package is production-ready and includes:
- ✅ Comprehensive error handling
- ✅ Rate limiting protection
- ✅ Security features
- ✅ Monitoring and analytics
- ✅ Battle-tested with real applications

</details>

<details>
<summary><strong>What's the difference between WhatsApp Business API and Cloud API?</strong></summary>

- **Business API**: Self-hosted, complex setup, enterprise features
- **Cloud API**: Meta-hosted, easy setup, perfect for most use cases
- **This package**: Designed for Cloud API (easier and more accessible)

</details>

<details>
<summary><strong>How do I handle large message volumes?</strong></summary>

For high-volume messaging:
1. Implement message queuing
2. Use multiple phone numbers
3. Configure appropriate rate limits
4. Monitor API quotas
5. Consider WhatsApp Business API for enterprise needs

</details>

## 📞 Support & Community

### Get Help
- **📚 [Documentation](https://pub.dev/documentation/whatsapp_cloud_flutter/latest/)** - Complete API reference
- **💬 [GitHub Discussions](https://github.com/swahiliconnect/whatsapp_cloud_flutter/discussions)** - Community Q&A
- **🐛 [Issue Tracker](https://github.com/swahiliconnect/whatsapp_cloud_flutter/issues)** - Bug reports and feature requests
- **📧 [Email Support](mailto:support@swahiliconnect.com)** - Direct support from SwahiliConnect

### Community
Join our growing community of developers using WhatsApp Cloud Flutter!

- **⭐ Star the repo** if you find it useful
- **🐦 Follow [@SwahiliConnect](https://twitter.com/swahiliconnect)** for updates
- **💼 [LinkedIn](https://linkedin.com/company/swahiliconnect)** - Professional updates
- **🌐 [Website](https://swahiliconnect.com)** - More about SwahiliConnect

## 👨‍💻 About the Author

This package is developed and maintained by **[Israel Biselu](https://github.com/israelbiselu)** from **[SwahiliConnect](https://swahiliconnect.com)** - a software development company focused on building solutions that connect communities across Africa.

### SwahiliConnect Mission
We believe in the power of technology to bridge communication gaps and enable businesses to reach their customers more effectively. This WhatsApp Cloud Flutter package is part of our commitment to providing high-quality, open-source tools for the developer community.

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](https://github.com/swahiliconnect/whatsapp_cloud_flutter/blob/main/LICENSE) file for details.

```
MIT License

Copyright (c) 2025 SwahiliConnect - Israel Biselu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

## 🚀 Complete Implementation Guides

### 🔌 Webhook Server Setup

The package includes webhook processing logic, but you'll need a server to receive webhooks. Here's a complete implementation:

<details>
<summary><strong>Click to see complete webhook server code</strong></summary>

```dart
// Add to pubspec.yaml: shelf: ^1.4.0

import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

class WhatsAppWebhookServer {
  final WhatsAppCloudClient whatsapp;
  final String verifyToken;
  
  WhatsAppWebhookServer({required this.whatsapp, required this.verifyToken});

  Future<void> start({String host = '0.0.0.0', int port = 8080}) async {
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler(_handleRequest);

    final server = await serve(handler, host, port);
    print('🚀 Webhook server running on ${server.address.host}:${server.port}');
    _setupWebhookHandlers();
  }

  Future<Response> _handleRequest(Request request) async {
    if (request.method == 'GET' && request.url.path == 'webhook') {
      return _handleVerification(request);
    } else if (request.method == 'POST' && request.url.path == 'webhook') {
      return await _handleWebhookEvent(request);
    }
    return Response.notFound('Endpoint not found');
  }

  Response _handleVerification(Request request) {
    final params = request.url.queryParameters;
    final mode = params['hub.mode'];
    final token = params['hub.verify_token'];
    final challenge = params['hub.challenge'];

    if (mode == 'subscribe' && token == verifyToken) {
      print('✅ Webhook verification successful!');
      return Response.ok(challenge);
    }
    print('❌ Webhook verification failed!');
    return Response.forbidden('Verification failed');
  }

  Future<Response> _handleWebhookEvent(Request request) async {
    try {
      final body = await request.readAsString();
      print('📨 Received webhook: $body');
      whatsapp.webhookService.processWebhook(body);
      return Response.ok('EVENT_RECEIVED');
    } catch (e) {
      print('❌ Error processing webhook: $e');
      return Response.internalServerError();
    }
  }

  void _setupWebhookHandlers() {
    whatsapp.webhookService.registerMessageHandler((event) {
      print('📱 New message from ${event.from}: ${event.text}');
      
      // Auto-reply example
      if (event.text?.toLowerCase().contains('hello') == true) {
        whatsapp.messageService.sendTextMessage(
          recipient: event.from,
          text: 'Hello! Thanks for your message.',
        );
      }
    });

    whatsapp.webhookService.registerStatusHandler((event) {
      print('📊 Message ${event.messageId} status: ${event.status}');
    });
  }
}

// Usage
void main() async {
  final whatsapp = WhatsAppCloudClient(
    phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
    accessToken: 'YOUR_ACCESS_TOKEN',
  );

  final server = WhatsAppWebhookServer(
    whatsapp: whatsapp,
    verifyToken: 'your_secure_verify_token',
  );

  await server.start(port: 8080);
}
```

**Setup Steps:**
1. Create webhook server file with code above
2. Run: `dart webhook_server.dart`
3. Use ngrok for testing: `ngrok http 8080`
4. Configure webhook URL in Meta Developer Console
5. Set verify token and subscribe to `messages`, `message_deliveries`

</details>

### 📸 Media Upload Implementation

The media service is fully functional. Here's how to integrate with Flutter's image picker:

<details>
<summary><strong>Click to see complete media upload implementation</strong></summary>

```dart
// Add to pubspec.yaml:
// image_picker: ^1.0.0
// file_picker: ^4.6.0

import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

class MediaUploadManager {
  final WhatsAppCloudClient _client;
  final ImagePicker _imagePicker = ImagePicker();
  
  MediaUploadManager({required String phoneNumberId, required String accessToken})
      : _client = WhatsAppCloudClient(phoneNumberId: phoneNumberId, accessToken: accessToken);

  // Upload and send image from gallery
  Future<bool> pickAndSendImage(String recipient) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return false;

      final bytes = await image.readAsBytes();
      
      // Upload to WhatsApp
      final uploadResponse = await _client.mediaService.uploadMediaBytes(
        mediaType: MediaType.image,
        bytes: bytes,
        mimeType: 'image/jpeg',
        filename: image.name,
      );

      if (uploadResponse.successful) {
        // Send the uploaded image
        final messageResponse = await _client.messageService.sendImageMessage(
          recipient: recipient,
          source: MediaSource.id,
          mediaId: uploadResponse.mediaId!,
          caption: 'Image from Flutter app!',
        );
        return messageResponse.successful;
      }
      return false;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // Upload from file path
  Future<String?> uploadFromFile(String filePath, MediaType mediaType) async {
    try {
      final file = File(filePath);
      final response = await _client.mediaService.uploadMedia(
        mediaType: mediaType,
        file: file,
      );
      return response.successful ? response.mediaId : null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  // Upload from URL
  Future<String?> uploadFromUrl(String url, MediaType mediaType) async {
    try {
      final response = await _client.mediaService.uploadMediaFromUrl(
        mediaType: mediaType,
        url: url,
      );
      return response.successful ? response.mediaId : null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}

// Usage in Flutter widget
class MediaUploadDemo extends StatefulWidget {
  @override
  _MediaUploadDemoState createState() => _MediaUploadDemoState();
}

class _MediaUploadDemoState extends State<MediaUploadDemo> {
  final _mediaManager = MediaUploadManager(
    phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
    accessToken: 'YOUR_ACCESS_TOKEN',
  );

  Future<void> _sendImage() async {
    final success = await _mediaManager.pickAndSendImage('+1234567890');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? '✅ Image sent!' : '❌ Failed to send')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _sendImage,
          child: Text('Pick & Send Image'),
        ),
      ),
    );
  }
}
```

**Media Type Limits:**
- Images: 5MB (JPEG, PNG)
- Videos: 16MB (MP4, 3GPP)
- Audio: 16MB (AAC, M4A, AMR, MP3, OGG)
- Documents: 100MB (PDF, DOC, DOCX, etc.)
- Stickers: 100KB (WebP)

</details>

### 📝 Template Management

Templates must be created in Meta Business Manager first, then approved before use:

<details>
<summary><strong>Click to see complete template management guide</strong></summary>

**Step 1: Create Templates in Meta Business Manager**
1. Go to [Meta Business Manager](https://business.facebook.com/)
2. Navigate to WhatsApp Manager → Message Templates
3. Click "Create Template"
4. Fill in details and wait for approval (24-48 hours)

**Step 2: Use Templates in Code**

```dart
class TemplateManager {
  final WhatsAppCloudClient _client;
  
  TemplateManager({required String phoneNumberId, required String accessToken})
      : _client = WhatsAppCloudClient(phoneNumberId: phoneNumberId, accessToken: accessToken);

  // Send simple template (no parameters)
  Future<bool> sendWelcomeTemplate(String recipient) async {
    try {
      final response = await _client.templateService.sendTemplate(
        recipient: recipient,
        templateName: 'hello_world', // Must match your approved template
        language: 'en_US',
      );
      return response.successful;
    } catch (e) {
      print('Template error: $e');
      return false;
    }
  }

  // Send template with parameters
  Future<bool> sendOrderConfirmation({
    required String recipient,
    required String customerName,
    required String orderNumber,
  }) async {
    try {
      // Template body: "Hi {{1}}, your order {{2}} is confirmed!"
      final response = await _client.templateService.sendTemplate(
        recipient: recipient,
        templateName: 'order_confirmation',
        language: 'en_US',
        components: [
          // Component implementation depends on your package's template component classes
          // Check the package documentation for exact syntax
        ],
      );
      return response.successful;
    } catch (e) {
      print('Template error: $e');
      return false;
    }
  }

  // List your approved templates
  Future<void> listTemplates() async {
    try {
      final templates = await _client.templateService.getTemplates();
      print('📋 Your templates:');
      for (final template in templates) {
        print('- ${template['name']} (${template['status']})');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
```

**Template Categories:**
- **UTILITY**: Order confirmations, appointment reminders (higher approval rate)
- **MARKETING**: Promotions, newsletters (stricter approval)
- **AUTHENTICATION**: OTP codes, verification (fastest approval)

**Template Approval Tips:**
- Use clear, professional language
- Avoid promotional language in UTILITY templates
- Include proper variable placeholders {{1}}, {{2}}
- Follow WhatsApp's content policy

</details>

### 🔧 First-Time Setup Checklist

**Prerequisites:**
- [ ] Meta Developer Account
- [ ] WhatsApp Business Account  
- [ ] WhatsApp Business App created
- [ ] Phone Number verified
- [ ] Access Token generated

**Basic Setup:**
- [ ] Add package to pubspec.yaml
- [ ] Initialize WhatsAppCloudClient
- [ ] Test basic text message sending
- [ ] Verify recipient receives message

**Advanced Setup (Optional):**
- [ ] Set up webhook server (for receiving messages)
- [ ] Configure media upload (for sending files)
- [ ] Create and approve templates (for business messaging)
- [ ] Implement error handling and logging
- [ ] Set up production security

**Testing:**
- [ ] Send test message to your own number
- [ ] Test webhook with ngrok
- [ ] Upload and send test media
- [ ] Verify template approval and sending

---

<div align="center">

**Made with ❤️ by [SwahiliConnect](https://swahiliconnect.com)**

[⭐ Star us on GitHub](https://github.com/swahiliconnect/whatsapp_cloud_flutter) • [🐛 Report Bug](https://github.com/swahiliconnect/whatsapp_cloud_flutter/issues) • [💡 Request Feature](https://github.com/swahiliconnect/whatsapp_cloud_flutter/discussions)

</div># whatsapp_cloud_flutter
