import 'package:flutter/material.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart' as whatsapp;

// WEBHOOK SERVER EXAMPLE
// 
// For webhook functionality in pure Dart environments (servers), you can
// copy the following code to a separate .dart file (e.g., webhook_server.dart)
// and run it as a standalone server.
//
// Complete webhook server implementation using WhatsAppCloudServerClient:
//
// ```dart
// import 'dart:io';
// import 'package:shelf/shelf.dart';
// import 'package:shelf/shelf_io.dart';
// import 'package:whatsapp_cloud_flutter/whatsapp_cloud_server_client.dart';
// import 'package:whatsapp_cloud_flutter/src/config/api_config.dart';
// import 'package:whatsapp_cloud_flutter/src/config/environment.dart';
// import 'package:whatsapp_cloud_flutter/src/utils/logger.dart';
//
// /// Configuration - Update these values
// class WebhookConfig {
//   static const String phoneNumberId = 'YOUR_PHONE_NUMBER_ID_HERE';
//   static const String accessToken = 'YOUR_ACCESS_TOKEN_HERE';
//   static const String verifyToken = 'your_secure_verify_token_here';
//   static const String host = '0.0.0.0';
//   static const int port = 8080;
// }
//
// class WhatsAppWebhookServer {
//   final WhatsAppCloudServerClient client;
//   final String verifyToken;
//   
//   WhatsAppWebhookServer({
//     required this.client,
//     required this.verifyToken,
//   });
//
//   Future<void> start({String host = '0.0.0.0', int port = 8080}) async {
//     final handler = Pipeline()
//         .addMiddleware(logRequests())
//         .addMiddleware(_corsMiddleware())
//         .addHandler(_router);
//
//     final server = await serve(handler, host, port);
//     print('🚀 WhatsApp Webhook Server Started!');
//     print('📍 Server: http://${server.address.host}:${server.port}');
//     print('🔗 Webhook URL: http://${server.address.host}:${server.port}/webhook');
//     print('🔐 Verify Token: $verifyToken');
//     
//     _setupWebhookHandlers();
//   }
//
//   Future<Response> _router(Request request) async {
//     final path = request.url.path;
//     final method = request.method;
//
//     try {
//       switch (path) {
//         case 'webhook':
//           if (method == 'GET') {
//             return _handleWebhookVerification(request);
//           } else if (method == 'POST') {
//             return await _handleWebhookEvent(request);
//           }
//           break;
//         case 'health':
//           return Response.ok('{"status": "healthy"}');
//         default:
//           return Response.notFound('Endpoint not found: $path');
//       }
//     } catch (e) {
//       print('❌ Error handling request: $e');
//       return Response.internalServerError(body: 'Internal server error');
//     }
//
//     return Response.notFound('Method not allowed: $method $path');
//   }
//
//   Response _handleWebhookVerification(Request request) {
//     final params = request.url.queryParameters;
//     final mode = params['hub.mode'];
//     final token = params['hub.verify_token'];
//     final challenge = params['hub.challenge'];
//
//     if (mode == 'subscribe' && token == verifyToken) {
//       print('✅ Webhook verification successful!');
//       return Response.ok(challenge);
//     } else {
//       print('❌ Webhook verification failed!');
//       return Response.forbidden('Verification failed');
//     }
//   }
//
//   Future<Response> _handleWebhookEvent(Request request) async {
//     try {
//       final body = await request.readAsString();
//       print('📨 Webhook Event Received');
//
//       // Process the webhook using the package's webhook service
//       client.webhookService.processWebhook(body);
//       
//       return Response.ok('EVENT_RECEIVED');
//     } catch (e) {
//       print('❌ Error processing webhook event: $e');
//       return Response.internalServerError(body: 'Error processing webhook');
//     }
//   }
//
//   void _setupWebhookHandlers() {
//     print('🔧 Setting up webhook handlers...');
//     
//     // Handle incoming messages
//     client.webhookService.registerMessageHandler((event) {
//       print('📱 New Message from ${event.from}: ${event.text}');
//       
//       // Auto-reply example
//       final text = event.text?.toLowerCase() ?? '';
//       if (text.contains('hello') || text.contains('hi')) {
//         _sendAutoReply(event.from, 'Hello! Thanks for contacting us.');
//       } else if (text.contains('help')) {
//         _sendAutoReply(event.from, 'I\'m here to help! Ask me anything.');
//       } else {
//         _sendAutoReply(event.from, 'Thanks for your message!');
//       }
//     });
//
//     // Handle message status updates
//     client.webhookService.registerStatusHandler((event) {
//       print('📊 Status Update: ${event.messageId} - ${event.status}');
//     });
//     
//     print('✅ Webhook handlers configured');
//   }
//
//   Future<void> _sendAutoReply(String recipient, String message) async {
//     try {
//       final response = await client.messageService.sendTextMessage(
//         recipient: recipient,
//         text: message,
//       );
//
//       if (response.successful) {
//         print('✅ Auto-reply sent successfully');
//       } else {
//         print('❌ Auto-reply failed: ${response.errorMessage}');
//       }
//     } catch (e) {
//       print('❌ Error in auto-reply: $e');
//     }
//   }
//
//   Middleware _corsMiddleware() {
//     return (Handler handler) {
//       return (Request request) async {
//         if (request.method == 'OPTIONS') {
//           return Response.ok('', headers: _corsHeaders);
//         }
//         
//         final response = await handler(request);
//         return response.change(headers: _corsHeaders);
//       };
//     };
//   }
//
//   Map<String, String> get _corsHeaders => {
//     'Access-Control-Allow-Origin': '*',
//     'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
//     'Access-Control-Allow-Headers': 'Content-Type, Authorization',
//     'Access-Control-Max-Age': '86400',
//   };
// }
//
// /// Main function to run the webhook server
// void main(List<String> args) async {
//   print('🚀 Starting WhatsApp Webhook Server...');
//   
//   // Check if configuration is needed
//   if (WebhookConfig.phoneNumberId == 'YOUR_PHONE_NUMBER_ID_HERE' ||
//       WebhookConfig.accessToken == 'YOUR_ACCESS_TOKEN_HERE') {
//     print('❌ Configuration Required!');
//     print('Please update the WebhookConfig class with your credentials');
//     exit(1);
//   }
//   
//   // Create the server client (uses in-memory storage, no Flutter dependencies)
//   final client = WhatsAppCloudServerClient(
//     phoneNumberId: WebhookConfig.phoneNumberId,
//     accessToken: WebhookConfig.accessToken,
//     config: const WhatsAppApiConfig(
//       environment: Environment.production,
//       logLevel: LogLevel.debug,
//     ),
//   );
//
//   final server = WhatsAppWebhookServer(
//     client: client,
//     verifyToken: WebhookConfig.verifyToken,
//   );
//   
//   try {
//     await server.start(
//       host: WebhookConfig.host,
//       port: WebhookConfig.port,
//     );
//     
//     print('Press Ctrl+C to stop the server');
//     await Future<void>.delayed(Duration(days: 365));
//   } catch (e) {
//     print('❌ Failed to start server: $e');
//     exit(1);
//   }
// }
// ```
//
// To run this webhook server:
// 1. Add 'shelf: ^1.4.0' to your pubspec.yaml dependencies
// 2. Copy the code above to a file like 'webhook_server.dart'
// 3. Update the WebhookConfig credentials with your actual values
// 4. Run: dart webhook_server.dart
// 5. Use ngrok to make it publicly accessible: ngrok http 8080
// 6. Configure the webhook URL in Meta Developer Console
//
// Key features:
// - Uses WhatsAppCloudServerClient (no Flutter UI dependencies)
// - Production-ready error handling and CORS support
// - Auto-reply functionality with webhook event handling
// - In-memory token storage (perfect for server environments)

// MEDIA UPLOAD EXAMPLE
// 
// To enable media upload functionality:
// 1. Add to pubspec.yaml:
//    image_picker: ^1.0.0
//    file_picker: ^4.6.0
// 2. Use this MediaUploadManager class:
//
// ```dart
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';
//
// class MediaUploadManager {
//   final WhatsAppCloudClient _client;
//   final ImagePicker _imagePicker = ImagePicker();
//   
//   MediaUploadManager(this._client);
//
//   // Upload and send image from gallery
//   Future<bool> pickAndSendImage(String recipient) async {
//     try {
//       final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
//       if (image == null) return false;
//
//       final bytes = await image.readAsBytes();
//       
//       // Upload to WhatsApp
//       final uploadResponse = await _client.mediaService.uploadMediaBytes(
//         mediaType: MediaType.image,
//         bytes: bytes,
//         mimeType: 'image/jpeg',
//         filename: image.name,
//       );
//
//       if (uploadResponse.successful) {
//         // Send the uploaded image
//         final messageResponse = await _client.messageService.sendImageMessage(
//           recipient: recipient,
//           source: MediaSource.id,
//           mediaId: uploadResponse.mediaId!,
//           caption: 'Image from Flutter app!',
//         );
//         return messageResponse.successful;
//       }
//       return false;
//     } catch (e) {
//       print('Error: $e');
//       return false;
//     }
//   }
//
//   // Upload from file path
//   Future<String?> uploadFromFile(String filePath, MediaType mediaType) async {
//     try {
//       final file = File(filePath);
//       final response = await _client.mediaService.uploadMedia(
//         mediaType: mediaType,
//         file: file,
//       );
//       return response.successful ? response.mediaId : null;
//     } catch (e) {
//       print('Upload error: $e');
//       return null;
//     }
//   }
// }
// ```

// TEMPLATE MANAGEMENT EXAMPLE
// 
// To use templates:
// 1. Create templates in Meta Business Manager first
// 2. Wait for approval (24-48 hours)
// 3. Use this TemplateManager class:
//
// ```dart
// class TemplateManager {
//   final WhatsAppCloudClient _client;
//   
//   TemplateManager(this._client);
//
//   // Send simple template (no parameters)
//   Future<bool> sendWelcomeTemplate(String recipient) async {
//     try {
//       final response = await _client.templateService.sendTemplate(
//         recipient: recipient,
//         templateName: 'hello_world', // Must match your approved template
//         language: 'en_US',
//       );
//       return response.successful;
//     } catch (e) {
//       print('Template error: $e');
//       return false;
//     }
//   }
//
//   // List your approved templates
//   Future<void> listTemplates() async {
//     try {
//       final templates = await _client.templateService.getTemplates();
//       print('📋 Your templates:');
//       for (final template in templates) {
//         print('- ${template['name']} (${template['status']})');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
// }
// ```

void main() {
  runApp(const WhatsAppExampleApp());
}

class WhatsAppExampleApp extends StatelessWidget {
  const WhatsAppExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Cloud API Example',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final _phoneNumberIdController = TextEditingController();
  final _accessTokenController = TextEditingController();
  final _recipientController = TextEditingController();
  final _messageController = TextEditingController();
  
  whatsapp.WhatsAppCloudClient? _client;
  String _status = 'Not connected';
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    // You can set default values here for testing
    _phoneNumberIdController.text = 'YOUR_PHONE_NUMBER_ID';
    _accessTokenController.text = 'YOUR_ACCESS_TOKEN';
    _recipientController.text = '+1234567890'; // Example recipient
  }

  @override
  void dispose() {
    _phoneNumberIdController.dispose();
    _accessTokenController.dispose();
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toIso8601String()}: $message');
      if (_logs.length > 10) _logs.removeLast();
    });
  }

  void _initializeClient() {
    try {
      _client = whatsapp.WhatsAppCloudClient(
        phoneNumberId: _phoneNumberIdController.text.trim(),
        accessToken: _accessTokenController.text.trim(),
        config: const whatsapp.WhatsAppApiConfig(
          logLevel: whatsapp.LogLevel.debug,
          environment: whatsapp.Environment.production,
          connectTimeout: Duration(seconds: 30),
          retryPolicy: whatsapp.RetryPolicy(
            maxRetries: 3,
            initialBackoff: Duration(seconds: 1),
          ),
        ),
      );
      
      setState(() {
        _status = 'Connected';
      });
      _addLog('WhatsApp client initialized successfully');
    } catch (e) {
      setState(() {
        _status = 'Connection failed: $e';
      });
      _addLog('Failed to initialize client: $e');
    }
  }

  Future<void> _sendTextMessage() async {
    if (_client == null) {
      _addLog('Please initialize the client first');
      return;
    }

    final message = _messageController.text.trim();
    final recipient = _recipientController.text.trim();

    if (message.isEmpty || recipient.isEmpty) {
      _addLog('Please enter both message and recipient');
      return;
    }

    try {
      _addLog('Sending text message...');
      final response = await _client!.messageService.sendTextMessage(
        recipient: recipient,
        text: message,
        previewUrl: true,
      );

      if (response.successful) {
        _addLog('✅ Message sent successfully! ID: ${response.messageId}');
        _messageController.clear();
      } else {
        _addLog('❌ Failed to send message: ${response.errorMessage}');
      }
    } catch (e) {
      _addLog('❌ Error sending message: $e');
    }
  }

  Future<void> _sendLocationMessage() async {
    if (_client == null) {
      _addLog('Please initialize the client first');
      return;
    }

    try {
      _addLog('Sending location message...');
      final response = await _client!.messageService.sendLocationMessage(
        recipient: _recipientController.text.trim(),
        latitude: 37.7749,
        longitude: -122.4194,
        name: 'San Francisco',
        address: 'San Francisco, CA, USA',
      );

      if (response.successful) {
        _addLog('✅ Location sent successfully! ID: ${response.messageId}');
      } else {
        _addLog('❌ Failed to send location: ${response.errorMessage}');
      }
    } catch (e) {
      _addLog('❌ Error sending location: $e');
    }
  }

  Future<void> _sendInteractiveMessage() async {
    if (_client == null) {
      _addLog('Please initialize the client first');
      return;
    }

    try {
      _addLog('Sending simple text message with URL preview...');
      final response = await _client!.messageService.sendTextMessage(
        recipient: _recipientController.text.trim(),
        text: 'Check out this website: https://flutter.dev',
        previewUrl: true,
      );

      if (response.successful) {
        _addLog('✅ Message with URL preview sent! ID: ${response.messageId}');
      } else {
        _addLog('❌ Failed to send message: ${response.errorMessage}');
      }
    } catch (e) {
      _addLog('❌ Error sending message: $e');
    }
  }

  Future<void> _markAsRead() async {
    if (_client == null) {
      _addLog('Please initialize the client first');
      return;
    }

    try {
      _addLog('Marking message as read...');
      // This would typically use a message ID from an incoming webhook
      const messageId = 'example_message_id';
      final response = await _client!.messageService.markMessageAsRead(messageId: messageId);

      if (response.successful) {
        _addLog('✅ Message marked as read');
      } else {
        _addLog('❌ Failed to mark as read: ${response.errorMessage}');
      }
    } catch (e) {
      _addLog('❌ Error marking as read: $e');
    }
  }

  void _testWebhookVerification() {
    try {
      _addLog('Testing webhook functionality...');
      
      // Example of how webhook verification would work
      const verifyToken = 'your_verify_token';
      const mode = 'subscribe';
      const challenge = '1234567890';
      
      // In a real app, this would be in your webhook endpoint
      if (mode == 'subscribe' && verifyToken == 'your_verify_token') {
        _addLog('✅ Webhook verification would succeed with challenge: $challenge');
      } else {
        _addLog('❌ Webhook verification would fail');
      }
      
      _addLog('📖 Note: In production, configure webhook URL in Meta Developer Console');
    } catch (e) {
      _addLog('❌ Webhook test error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Cloud API Example'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Configuration Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneNumberIdController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _accessTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Access Token',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _recipientController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Phone (+1234567890)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _initializeClient,
                          child: const Text('Initialize Client'),
                        ),
                        const SizedBox(width: 12),
                        Text('Status: $_status'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Message Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Send Messages',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message Text',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _sendTextMessage,
                          icon: const Icon(Icons.message),
                          label: const Text('Send Text'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _sendLocationMessage,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Send Location'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _sendInteractiveMessage,
                          icon: const Icon(Icons.link),
                          label: const Text('URL Preview'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _markAsRead,
                          icon: const Icon(Icons.mark_as_unread),
                          label: const Text('Mark Read'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _testWebhookVerification,
                          icon: const Icon(Icons.webhook),
                          label: const Text('Test Webhook'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Logs Section
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Activity Logs',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _logs.clear()),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _logs.isEmpty
                              ? const Text(
                                  'No activity yet. Initialize the client and try sending a message.',
                                  style: TextStyle(color: Colors.grey),
                                )
                              : ListView.builder(
                                  itemCount: _logs.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Text(
                                        _logs[index],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}