# WhatsApp Cloud Flutter

[![pub package](https://img.shields.io/pub/v/whatsapp_cloud_flutter.svg)](https://pub.dev/packages/whatsapp_cloud_flutter)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/swahiliconnect/whatsapp_cloud_flutter/blob/main/LICENSE)

A comprehensive Flutter package that provides a type-safe, easy-to-use wrapper around Meta's WhatsApp Cloud API. This package enables Flutter developers to integrate WhatsApp messaging capabilities into their applications with minimal effort, handling the complexities of API interactions, authentication, and message formatting.

## Features

- 📱 **Simple Authentication** - Easy connection to WhatsApp Cloud API
- 💬 **Rich Messaging** - Send and receive various message types:
  - Text messages with URL previews
  - Media messages (images, videos, audio, documents, stickers)
  - Interactive messages with buttons and lists
  - Location messages
  - Contact card messages
  - Template messages
- 📋 **Template Management** - Work with message templates including retrieval, creation, and sending
- 📁 **Media Management** - Upload, download, and manage media files
- 🔔 **Webhook Handling** - Process incoming messages and status updates
- ⚡ **Rate Limiting** - Built-in rate limiting to prevent API quota issues
- 🔄 **Retry Mechanism** - Automatic retry for failed requests with exponential backoff
- 🪵 **Comprehensive Logging** - Detailed logging for debugging and monitoring
- 🛠️ **Flutter UI Components** - Ready-to-use Flutter widgets for common WhatsApp messaging UI elements

## Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  whatsapp_cloud_flutter: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Getting Started

### Prerequisites

1. A Meta Developer account
2. A WhatsApp Business account
3. Access to the WhatsApp Cloud API
4. A Phone Number ID and access token

### Basic Usage

First, initialize the WhatsApp Cloud client:

```dart
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

final whatsappClient = WhatsAppCloudClient(
  phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
  accessToken: 'YOUR_ACCESS_TOKEN',
  environment: Environment.production,
);
```

### Sending a Text Message

```dart
try {
  final response = await whatsappClient.messageService.sendTextMessage(
    recipient: '+1234567890',
    text: 'Hello from Flutter!',
    previewUrl: true,
  );

  if (response.successful) {
    print('Message sent with ID: ${response.messageId}');
  } else {
    print('Failed to send message: ${response.errorMessage}');
  }
} catch (e) {
  print('Error sending message: $e');
}
```

### Sending a Media Message

```dart
// Send an image message
final response = await whatsappClient.messageService.sendImageMessage(
  recipient: '+1234567890',
  source: MediaSource.url,
  mediaUrl: 'https://example.com/image.jpg',
  caption: 'Check out this image!',
);

// Send a document message
final response = await whatsappClient.messageService.sendDocumentMessage(
  recipient: '+1234567890',
  source: MediaSource.url,
  mediaUrl: 'https://example.com/document.pdf',
  caption: 'Here is the document you requested',
  filename: 'document.pdf',
);
```

### Sending a Template Message

```dart
final response = await whatsappClient.templateService.sendTemplate(
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
  ],
);
```

### Uploading Media

```dart
final mediaResponse = await whatsappClient.mediaService.uploadMedia(
  mediaType: MediaType.image,
  file: File('path/to/image.jpg'),
);

if (mediaResponse.successful) {
  // Use the media ID for sending media messages
  final mediaId = mediaResponse.mediaId;
  
  final response = await whatsappClient.messageService.sendImageMessage(
    recipient: '+1234567890',
    source: MediaSource.id,
    mediaId: mediaId,
    caption: 'Image uploaded and sent via WhatsApp Cloud API',
  );
}
```

### Handling Webhooks

```dart
// Register webhook handlers
whatsappClient.webhookService.registerMessageHandler(
  (messageEvent) {
    print('Received message: ${messageEvent.text} from ${messageEvent.from}');
    
    // You can reply to incoming messages
    whatsappClient.messageService.sendTextMessage(
      recipient: messageEvent.from,
      text: 'Thanks for your message!',
    );
  }
);

whatsappClient.webhookService.registerStatusHandler(
  (statusEvent) {
    print('Message ${statusEvent.messageId} status: ${statusEvent.status}');
  }
);

// Process an incoming webhook payload
final webhookPayload = getWebhookPayloadFromRequest(); // Your implementation
whatsappClient.webhookService.processWebhook(webhookPayload);
```

### Using the UI Components

The package includes ready-to-use Flutter widgets:

```dart
// Message composer
MessageComposer(
  messageService: whatsappClient.messageService,
  recipient: '+1234567890',
  placeholder: 'Type your message...',
  onMessageSent: (messageId) {
    print('Message sent with ID: $messageId');
  },
  onError: (error) {
    print('Error: $error');
  },
)

// Template selector
TemplateSelector(
  templateService: whatsappClient.templateService,
  recipient: '+1234567890',
  languageCode: 'en_US',
  onTemplateSent: (messageId) {
    print('Template sent with ID: $messageId');
  },
)

// Chat bubble
ChatBubble(
  message: 'Hello, how can I help you?',
  alignment: BubbleAlignment.left,
  timestamp: DateTime.now(),
  senderName: 'Support Agent',
)
```

## Error Handling

The package provides a comprehensive error handling system:

```dart
try {
  final response = await whatsappClient.messageService.sendTextMessage(
    recipient: '+1234567890',
    text: 'Hello from Flutter!',
  );
} on AuthException catch (e) {
  // Handle authentication errors
  print('Auth error: ${e.message}');
} on RateLimitException catch (e) {
  // Handle rate limiting
  print('Rate limited, retry after: ${e.retryAfter}');
} on MessageException catch (e) {
  // Handle message-specific errors
  print('Message error: ${e.code} - ${e.message}');
} on ApiException catch (e) {
  // Handle general API errors
  print('API error: ${e.statusCode} - ${e.message}');
} catch (e) {
  // Handle unexpected errors
  print('Unexpected error: $e');
}
```

## Configuration Options

You can customize the client with advanced configuration options:

```dart
final config = WhatsAppApiConfig(
  baseUrl: 'https://graph.facebook.com/v16.0',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  logLevel: LogLevel.debug,
  retryPolicy: RetryPolicy(
    maxRetries: 3,
    initialBackoff: Duration(seconds: 1),
    maxBackoff: Duration(seconds: 10),
  ),
);

final whatsappClient = WhatsAppCloudClient(
  phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
  accessToken: 'YOUR_ACCESS_TOKEN',
  config: config,
);
```

## Examples

Check out the [example](https://github.com/swahiliconnect/whatsapp_cloud_flutter/tree/main/example) directory for complete working examples, including:

- Simple text messaging
- Template messaging
- Media sharing
- Webhook handling

## Documentation

For complete documentation, visit:
- [API Reference](https://pub.dev/documentation/whatsapp_cloud_flutter/latest/)
- [WhatsApp Cloud API Documentation](https://developers.facebook.com/docs/whatsapp/cloud-api/)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.