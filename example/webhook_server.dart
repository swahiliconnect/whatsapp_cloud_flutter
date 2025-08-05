#!/usr/bin/env dart

/// Simplified WhatsApp Webhook Server for pure Dart environments
/// 
/// This server uses in-memory storage instead of Flutter's SharedPreferences
/// to avoid Flutter UI dependencies in server environments.
/// 
/// Setup:
/// 1. Ensure shelf: ^1.4.0 is added to pubspec.yaml
/// 2. Update configuration below with your credentials
/// 3. Run: dart webhook_server_simple.dart
/// 4. Use ngrok to make it public: ngrok http 8080
/// 5. Configure webhook URL in Meta Developer Console

import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_server_client.dart';
import 'package:whatsapp_cloud_flutter/src/config/api_config.dart';
import 'package:whatsapp_cloud_flutter/src/config/environment.dart';
import 'package:whatsapp_cloud_flutter/src/utils/logger.dart';

/// Configuration - Update these values
class WebhookConfig {
  static const String phoneNumberId = 'YOUR_PHONE_NUMBER_ID_HERE';
  static const String accessToken = 'YOUR_ACCESS_TOKEN_HERE';
  static const String verifyToken = 'your_secure_verify_token_here';
  static const String host = '0.0.0.0';
  static const int port = 8080;
}

class SimpleWhatsAppWebhookServer {
  final WhatsAppCloudServerClient client;
  final String verifyToken;
  
  SimpleWhatsAppWebhookServer({
    required this.client,
    required this.verifyToken,
  });

  Future<void> start({String host = '0.0.0.0', int port = 8080}) async {
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler(_router);

    final server = await serve(handler, host, port);
    print('🚀 WhatsApp Webhook Server Started!');
    print('📍 Server: http://${server.address.host}:${server.port}');
    print('🔗 Webhook URL: http://${server.address.host}:${server.port}/webhook');
    print('🔐 Verify Token: $verifyToken');
    print('');
    print('📋 Next Steps:');
    print('1. Make this server publicly accessible (use ngrok for testing)');
    print('2. Configure webhook in Meta Developer Console');
    print('3. Test by sending a message to your WhatsApp Business number');
    print('');
    
    _setupWebhookHandlers();
  }

  Future<Response> _router(Request request) async {
    final path = request.url.path;
    final method = request.method;

    print('📨 $method /$path');

    try {
      switch (path) {
        case 'webhook':
          if (method == 'GET') {
            return _handleWebhookVerification(request);
          } else if (method == 'POST') {
            return await _handleWebhookEvent(request);
          }
          break;
        case 'health':
          return Response.ok('{"status": "healthy"}');
        case '':
          return _handleRoot();
        default:
          return Response.notFound('Endpoint not found: $path');
      }
    } catch (e) {
      print('❌ Error handling request: $e');
      return Response.internalServerError(body: 'Internal server error');
    }

    return Response.notFound('Method not allowed: $method $path');
  }

  Response _handleWebhookVerification(Request request) {
    final params = request.url.queryParameters;
    final mode = params['hub.mode'];
    final token = params['hub.verify_token'];
    final challenge = params['hub.challenge'];

    print('🔍 Webhook Verification:');
    print('  Mode: $mode');
    print('  Token: $token');
    print('  Challenge: $challenge');

    if (mode == 'subscribe' && token == verifyToken) {
      print('✅ Webhook verification successful!');
      return Response.ok(challenge);
    } else {
      print('❌ Webhook verification failed!');
      return Response.forbidden('Verification failed');
    }
  }

  Future<Response> _handleWebhookEvent(Request request) async {
    try {
      final body = await request.readAsString();
      print('📨 Webhook Event Received: ${body.length > 200 ? '${body.substring(0, 200)}...' : body}');

      // Process the webhook using the package's webhook service
      client.webhookService.processWebhook(body);
      
      return Response.ok('EVENT_RECEIVED');
    } catch (e) {
      print('❌ Error processing webhook event: $e');
      return Response.internalServerError(body: 'Error processing webhook');
    }
  }

  Response _handleRoot() {
    final html = '''
<!DOCTYPE html>
<html>
<head>
    <title>WhatsApp Webhook Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 8px; max-width: 600px; }
        .status { color: #00a650; font-weight: bold; }
        .code { background: #f0f0f0; padding: 10px; border-radius: 4px; font-family: monospace; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 WhatsApp Webhook Server</h1>
        <p class="status">✅ Server is running and ready!</p>
        
        <h3>📋 Configuration</h3>
        <div class="code">
            Webhook URL: http://localhost:${WebhookConfig.port}/webhook<br>
            Verify Token: ${WebhookConfig.verifyToken}
        </div>
        
        <h3>🔗 Endpoints</h3>
        <ul>
            <li><strong>GET /webhook</strong> - Webhook verification</li>
            <li><strong>POST /webhook</strong> - Receive webhook events</li>
            <li><strong>GET /health</strong> - Health check</li>
        </ul>
        
        <h3>⚠️ Setup Required</h3>
        <ol>
            <li>Update credentials in WebhookConfig</li>
            <li>Make server public (use ngrok for testing)</li>
            <li>Configure webhook URL in Meta Developer Console</li>
        </ol>
    </div>
</body>
</html>
''';
    
    return Response.ok(html, headers: {'Content-Type': 'text/html'});
  }

  void _setupWebhookHandlers() {
    print('🔧 Setting up webhook handlers...');
    
    // Handle incoming messages
    client.webhookService.registerMessageHandler((event) {
      print('📱 New Message:');
      print('  From: ${event.from}');
      print('  Type: ${event.messageType}');
      print('  Content: ${event.text ?? 'N/A'}');
      
      // Auto-reply example
      final text = event.text?.toLowerCase() ?? '';
      if (text.contains('hello') || text.contains('hi')) {
        _sendAutoReply(event.from, 'Hello! Thanks for contacting us. How can I help you today?');
      } else if (text.contains('help')) {
        _sendAutoReply(event.from, 'I\'m here to help! You can ask me about our services.');
      } else {
        _sendAutoReply(event.from, 'Thanks for your message! We\'ll get back to you soon.');
      }
    });

    // Handle message status updates
    client.webhookService.registerStatusHandler((event) {
      print('📊 Status Update:');
      print('  Message ID: ${event.messageId}');
      print('  Status: ${event.status}');
      print('  Recipient: ${event.recipient}');
    });
    
    print('✅ Webhook handlers configured');
  }

  Future<void> _sendAutoReply(String recipient, String message) async {
    try {
      print('🤖 Sending auto-reply to $recipient: $message');
      
      final response = await client.messageService.sendTextMessage(
        recipient: recipient,
        text: message,
      );

      if (response.successful) {
        print('✅ Auto-reply sent successfully');
      } else {
        print('❌ Auto-reply failed: ${response.errorMessage}');
      }
    } catch (e) {
      print('❌ Error in auto-reply: $e');
    }
  }

  Middleware _corsMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        
        final response = await handler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  Map<String, String> get _corsHeaders => {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Max-Age': '86400',
  };
}

/// Main function to run the webhook server
void main(List<String> args) async {
  print('🚀 Starting WhatsApp Webhook Server...');
  print('');
  
  // Check if configuration is needed
  if (WebhookConfig.phoneNumberId == 'YOUR_PHONE_NUMBER_ID_HERE' ||
      WebhookConfig.accessToken == 'YOUR_ACCESS_TOKEN_HERE') {
    print('❌ Configuration Required!');
    print('');
    print('Please update the WebhookConfig class with your credentials:');
    print('1. phoneNumberId: Your WhatsApp Business Phone Number ID');
    print('2. accessToken: Your WhatsApp Cloud API Access Token');
    print('3. verifyToken: A secure token for webhook verification');
    print('');
    print('Get these values from: https://developers.facebook.com/apps/');
    print('');
    exit(1);
  }
  
  // Create the server client
  final client = WhatsAppCloudServerClient(
    phoneNumberId: WebhookConfig.phoneNumberId,
    accessToken: WebhookConfig.accessToken,
    config: const WhatsAppApiConfig(
      environment: Environment.production,
      logLevel: LogLevel.debug,
    ),
  );

  final server = SimpleWhatsAppWebhookServer(
    client: client,

    verifyToken: WebhookConfig.verifyToken,
  );
  
  try {
    await server.start(
      host: WebhookConfig.host,
      port: WebhookConfig.port,
    );
    
    print('Press Ctrl+C to stop the server');
    
    // Keep the server running
    await Future<void>.delayed(Duration(days: 365));
  } catch (e) {
    print('❌ Failed to start server: $e');
    exit(1);
  }
}