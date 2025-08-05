# WhatsApp Cloud API Webhook Communication Guide

## 🌐 How Webhooks Work with WhatsApp Cloud API

### Communication Architecture

```
┌─────────────────┐    HTTPS Requests     ┌──────────────────┐
│   Your Flutter  │ ────────────────────► │ WhatsApp Cloud   │
│      App        │                       │      API         │
│                 │ ◄──────────────────── │ (Meta's servers) │
└─────────────────┘   Webhook Events      └──────────────────┘
         │                                          │
         │                                          │
         ▼                                          ▼
┌─────────────────┐                       ┌──────────────────┐
│  Your Webhook   │                       │   WhatsApp       │
│   Server        │                       │  User's Phone    │
│ (Backend API)   │                       │                  │
└─────────────────┘                       └──────────────────┘
```

## 🔄 Two-Way Communication Explained

### 1. **Outbound: Your App → WhatsApp Cloud API**

When your Flutter app sends messages:

```dart
// Your Flutter app makes HTTPS requests to Meta's API
final response = await whatsapp.messageService.sendTextMessage(
  recipient: '+1234567890',
  text: 'Hello from Flutter!',
);

// This sends a POST request to:
// https://graph.facebook.com/v18.0/{phone-number-id}/messages
```

**Request Flow:**
1. Flutter app → Your backend (optional)
2. Your backend/Flutter → WhatsApp Cloud API (graph.facebook.com)
3. WhatsApp Cloud API → WhatsApp servers
4. WhatsApp servers → Recipient's phone

### 2. **Inbound: WhatsApp Cloud API → Your Webhook**

When events happen (message delivered, user replies, etc.):

```dart
// WhatsApp sends POST requests to YOUR webhook URL
// POST https://your-domain.com/webhook
// {
//   "object": "whatsapp_business_account",
//   "entry": [
//     {
//       "id": "WHATSAPP_BUSINESS_ACCOUNT_ID",
//       "changes": [
//         {
//           "value": {
//             "messaging_product": "whatsapp",
//             "metadata": {...},
//             "messages": [...],  // Incoming messages
//             "statuses": [...]   // Message status updates
//           }
//         }
//       ]
//     }
//   ]
// }
```

## 🛠️ Setting Up Webhooks

### Step 1: Create a Webhook Endpoint

You need a **publicly accessible HTTPS server** that can receive POST requests:

```dart
// Example webhook server (using Dart shelf)
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

Future<void> main() async {
  final whatsapp = WhatsAppCloudClient(
    phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
    accessToken: 'YOUR_ACCESS_TOKEN',
  );

  // Webhook handler
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler((request) async {
    
    if (request.method == 'GET') {
      // Webhook verification (required by Meta)
      return handleWebhookVerification(request);
    }
    
    if (request.method == 'POST') {
      // Handle incoming webhook events
      final body = await request.readAsString();
      return handleWebhookEvent(body, whatsapp);
    }
    
    return Response.notFound('Not found');
  });

  // Start server
  final server = await serve(handler, '0.0.0.0', 443);
  print('Webhook server running on ${server.address.host}:${server.port}');
}

// Webhook verification (GET request)
Response handleWebhookVerification(Request request) {
  final mode = request.url.queryParameters['hub.mode'];
  final token = request.url.queryParameters['hub.verify_token'];
  final challenge = request.url.queryParameters['hub.challenge'];
  
  const expectedToken = 'YOUR_VERIFY_TOKEN'; // Set this in Meta Developer Console
  
  if (mode == 'subscribe' && token == expectedToken) {
    print('✅ Webhook verified successfully');
    return Response.ok(challenge);
  }
  
  print('❌ Webhook verification failed');
  return Response.forbidden('Forbidden');
}

// Handle webhook events (POST request)
Future<Response> handleWebhookEvent(String body, WhatsAppCloudClient whatsapp) async {
  try {
    // Process the webhook payload
    whatsapp.webhookService.processWebhook(body);
    
    // Example: Auto-reply to incoming messages
    whatsapp.webhookService.registerMessageHandler((messageEvent) async {
      print('📨 Received message: ${messageEvent.text} from ${messageEvent.from}');
      
      // Auto-reply
      await whatsapp.messageService.sendTextMessage(
        recipient: messageEvent.from,
        text: 'Thanks for your message! We received: "${messageEvent.text}"',
      );
    });
    
    return Response.ok('EVENT_RECEIVED');
  } catch (e) {
    print('❌ Error processing webhook: $e');
    return Response.internalServerError();
  }
}
```

### Step 2: Configure Webhook in Meta Developer Console

1. **Go to Meta Developers Console**
   - Visit https://developers.facebook.com/
   - Select your WhatsApp Business App

2. **Configure Webhook**
   ```
   Webhook URL: https://your-domain.com/webhook
   Verify Token: YOUR_VERIFY_TOKEN (choose any string)
   ```

3. **Subscribe to Events**
   - ✅ messages (incoming messages)
   - ✅ message_deliveries (delivery status)
   - ✅ message_reads (read receipts)
   - ✅ message_reactions (reactions)

### Step 3: Test Webhook Connection

```dart
// Test webhook with your Flutter app
void testWebhook() async {
  final whatsapp = WhatsAppCloudClient(
    phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
    accessToken: 'YOUR_ACCESS_TOKEN',
  );
  
  // Send a test message
  await whatsapp.messageService.sendTextMessage(
    recipient: 'YOUR_TEST_NUMBER',
    text: 'Testing webhook integration!',
  );
  
  // Your webhook should receive delivery status updates
}
```

## 📱 Complete Integration Example

### Flutter App Integration

```dart
class WhatsAppChatService {
  late WhatsAppCloudClient _whatsapp;
  
  void initialize() {
    _whatsapp = WhatsAppCloudClient(
      phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
      accessToken: 'YOUR_ACCESS_TOKEN',
    );
    
    // Register webhook handlers
    _setupWebhookHandlers();
  }
  
  void _setupWebhookHandlers() {
    // Handle incoming messages
    _whatsapp.webhookService.registerMessageHandler((messageEvent) {
      print('📨 New message: ${messageEvent.text}');
      // Update your Flutter UI
      _updateChatUI(messageEvent);
    });
    
    // Handle message status updates
    _whatsapp.webhookService.registerStatusHandler((statusEvent) {
      print('📊 Message ${statusEvent.messageId} is ${statusEvent.status}');
      // Update message status in UI
      _updateMessageStatus(statusEvent.messageId, statusEvent.status);
    });
    
    // Handle button clicks
    _whatsapp.webhookService.registerInteractiveHandler((interactiveEvent) {
      print('🎯 Button clicked: ${interactiveEvent.buttonId}');
      // Handle user interactions
      _handleButtonClick(interactiveEvent);
    });
  }
  
  // Send message from Flutter app
  Future<void> sendMessage(String recipient, String text) async {
    final response = await _whatsapp.messageService.sendTextMessage(
      recipient: recipient,
      text: text,
    );
    
    if (response.successful) {
      // Message sent successfully
      // Webhook will receive delivery updates
    }
  }
  
  void _updateChatUI(MessageEvent event) {
    // Update your Flutter chat UI with new message
  }
  
  void _updateMessageStatus(String messageId, String status) {
    // Update message status indicators in UI
  }
  
  void _handleButtonClick(InteractiveEvent event) {
    // Handle user button interactions
  }
}
```

## 🔒 Webhook Security

### 1. **Signature Verification**

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

bool verifyWebhookSignature(String payload, String signature, String secret) {
  // Remove 'sha256=' prefix if present
  final cleanSignature = signature.replaceFirst('sha256=', '');
  
  // Calculate expected signature
  final key = utf8.encode(secret);
  final bytes = utf8.encode(payload);
  final hmacSha256 = Hmac(sha256, key);
  final digest = hmacSha256.convert(bytes);
  final expectedSignature = digest.toString();
  
  // Compare signatures
  return cleanSignature == expectedSignature;
}

// Use in your webhook handler
Future<Response> handleWebhookEvent(Request request) async {
  final signature = request.headers['x-hub-signature-256'] ?? '';
  final payload = await request.readAsString();
  
  if (!verifyWebhookSignature(payload, signature, 'YOUR_WEBHOOK_SECRET')) {
    return Response.forbidden('Invalid signature');
  }
  
  // Process webhook...
}
```

### 2. **HTTPS Only**
- Webhooks **must** use HTTPS (not HTTP)
- Use SSL certificates (Let's Encrypt is free)

### 3. **IP Whitelisting** (Optional)
- Restrict webhook access to Meta's IP ranges
- Check Meta's documentation for current IP ranges

## 🌐 Webhook Hosting Options

### 1. **Cloud Platforms**
```bash
# Deploy to Google Cloud Run
gcloud run deploy whatsapp-webhook \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

# Deploy to AWS Lambda
serverless deploy

# Deploy to Heroku
git push heroku main
```

### 2. **Local Development (ngrok)**
```bash
# Install ngrok
npm install -g ngrok

# Start your local server
dart run bin/webhook_server.dart

# Expose local server to internet
ngrok http 8080

# Use the ngrok URL as your webhook URL
# https://abc123.ngrok.io/webhook
```

### 3. **VPS/Dedicated Server**
```bash
# Install SSL certificate
sudo certbot --nginx -d your-domain.com

# Configure nginx
location /webhook {
    proxy_pass http://localhost:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

## 📊 Webhook Event Types

Your webhook will receive these types of events:

### **1. Message Events**
```json
{
  "messages": [
    {
      "from": "1234567890",
      "id": "wamid.HBgNMTc3...",
      "timestamp": "1634567890",
      "type": "text",
      "text": {
        "body": "Hello!"
      }
    }
  ]
}
```

### **2. Status Events**
```json
{
  "statuses": [
    {
      "id": "wamid.HBgNMTc3...",
      "status": "delivered",
      "timestamp": "1634567890",
      "recipient_id": "1234567890"
    }
  ]
}
```

### **3. Interactive Events**
```json
{
  "messages": [
    {
      "from": "1234567890",
      "type": "interactive",
      "interactive": {
        "type": "button_reply",
        "button_reply": {
          "id": "confirm_booking",
          "title": "Confirm"
        }
      }
    }
  ]
}
```

## 🚀 Production Checklist

### ✅ **Before Going Live:**

1. **Webhook Security**
   - [ ] HTTPS enabled with valid SSL certificate
   - [ ] Signature verification implemented
   - [ ] Input validation and sanitization
   - [ ] Rate limiting on webhook endpoint

2. **Error Handling**
   - [ ] Graceful error handling in webhook
   - [ ] Logging and monitoring
   - [ ] Retry mechanisms for failed processing
   - [ ] Dead letter queue for problematic events

3. **Performance**
   - [ ] Webhook responds within 20 seconds
   - [ ] Asynchronous processing for heavy tasks
   - [ ] Database/cache optimization
   - [ ] Load balancing if needed

4. **Testing**
   - [ ] Test all webhook event types
   - [ ] Test with actual WhatsApp messages
   - [ ] Load testing for high volume
   - [ ] Failover testing

5. **Monitoring**
   - [ ] Webhook uptime monitoring
   - [ ] Error rate alerts
   - [ ] Performance metrics
   - [ ] Log aggregation

## 🔧 Troubleshooting Common Issues

### **Webhook Not Receiving Events**
1. Check webhook URL is publicly accessible
2. Verify HTTPS certificate is valid
3. Ensure webhook returns 200 status code
4. Check Meta Developer Console webhook status

### **Verification Failed**
1. Verify token must match exactly
2. Check for typos in verification code
3. Ensure GET request handler is implemented

### **Message Processing Errors**
1. Add comprehensive error logging
2. Validate JSON payload structure
3. Handle malformed requests gracefully
4. Check signature verification

This complete webhook integration allows real-time, bidirectional communication between your Flutter app and WhatsApp users through Meta's Cloud API!
