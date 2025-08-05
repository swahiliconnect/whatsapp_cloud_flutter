# WhatsApp Cloud Flutter Example

This example demonstrates how to use the WhatsApp Cloud Flutter package to integrate WhatsApp messaging into your Flutter application.

## 🚀 Quick Start

### 1. Setup Credentials

1. Get your WhatsApp Business credentials from [Meta Developer Console](https://developers.facebook.com/)
2. Update the credentials in `lib/main.dart`:
   ```dart
   _phoneNumberIdController.text = 'YOUR_ACTUAL_PHONE_NUMBER_ID';
   _accessTokenController.text = 'YOUR_ACTUAL_ACCESS_TOKEN';
   ```

### 2. Run the Example

```bash
cd example
flutter pub get
flutter run
```

### 3. Test Basic Messaging

1. Enter your recipient's phone number (with country code, e.g., +1234567890)
2. Type a message and click "Send Text"
3. Check the recipient's WhatsApp for your message!

## 📱 What's Included

The example app demonstrates:

- ✅ **Basic text messaging** with URL previews
- ✅ **Location sharing** with GPS coordinates
- ✅ **Message status tracking** (mark as read)
- ✅ **Error handling** and logging
- ✅ **Configuration management**

## 🔌 Advanced Features

### Webhook Server Setup

For receiving incoming messages and status updates:

1. **Add dependency** to `pubspec.yaml`:
   ```yaml
   dependencies:
     shelf: ^1.4.0  # Uncomment this line
   ```

2. **Configure webhook server**:
   Update credentials in `webhook_server.dart`:
   ```dart
   static const String phoneNumberId = 'YOUR_PHONE_NUMBER_ID';
   static const String accessToken = 'YOUR_ACCESS_TOKEN';
   static const String verifyToken = 'your_secure_verify_token';
   ```

3. **Run webhook server**:
   ```bash
   dart webhook_server.dart
   ```

4. **Make it public** (for testing):
   ```bash
   # Install ngrok from https://ngrok.com
   ngrok http 8080
   ```

5. **Configure in Meta Console**:
   - Webhook URL: `https://your-ngrok-url.ngrok.io/webhook`
   - Verify Token: `your_secure_verify_token`
   - Subscribe to: `messages`, `message_deliveries`

### Media Upload Integration

For sending images, videos, and documents:

1. **Add dependencies** to `pubspec.yaml`:
   ```yaml
   dependencies:
     image_picker: ^1.0.0    # Uncomment this line
     file_picker: ^4.6.0     # Uncomment this line
   ```

2. **Use the MediaUploadManager** (see commented code in `main.dart`)

3. **Example usage**:
   ```dart
   final mediaManager = MediaUploadManager(_client);
   final success = await mediaManager.pickAndSendImage('+1234567890');
   ```

### Template Management

For business messaging with approved templates:

1. **Create templates** in [Meta Business Manager](https://business.facebook.com/)
2. **Wait for approval** (24-48 hours typically)
3. **Use TemplateManager** (see commented code in `main.dart`)
4. **Example usage**:
   ```dart
   final templateManager = TemplateManager(_client);
   await templateManager.sendWelcomeTemplate('+1234567890');
   ```

## 🔧 Configuration

### Environment Setup

The example supports different configurations:

```dart
// Development (with debug logging)
final client = WhatsAppCloudClient(
  phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
  accessToken: 'YOUR_ACCESS_TOKEN',
  config: const WhatsAppApiConfig(
    environment: Environment.production,
    logLevel: LogLevel.debug,
  ),
);

// Production (minimal logging)
final client = WhatsAppCloudClient(
  phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
  accessToken: 'YOUR_ACCESS_TOKEN',
  config: const WhatsAppApiConfig(
    environment: Environment.production,
    logLevel: LogLevel.warning,
  ),
);
```

### Security Best Practices

- ✅ Never hardcode credentials in production
- ✅ Use environment variables or secure storage
- ✅ Implement proper error handling
- ✅ Enable webhook signature verification for production

## 📊 Testing

### Test Checklist

- [ ] Basic text message sending works
- [ ] Recipient receives messages
- [ ] Error handling displays properly
- [ ] Webhook server starts without errors
- [ ] Webhook verification works
- [ ] Auto-reply functionality works
- [ ] Media upload and sending works
- [ ] Template messages work (after approval)

### Debugging Tips

1. **Enable debug logging**:
   ```dart
   logLevel: LogLevel.debug
   ```

2. **Check API connectivity**:
   ```dart
   try {
     final response = await client.messageService.sendTextMessage(
       recipient: 'YOUR_PHONE_NUMBER',
       text: 'Test message',
     );
     print('API Status: ${response.successful}');
   } catch (e) {
     print('API Error: $e');
   }
   ```

3. **Test webhook locally**:
   ```bash
   curl -X GET "http://localhost:8080/webhook?hub.mode=subscribe&hub.challenge=test&hub.verify_token=your_verify_token"
   ```

## 🆘 Common Issues

### Authentication Errors
- Verify Phone Number ID is correct
- Check Access Token hasn't expired
- Ensure proper permissions in Meta Console

### Message Delivery Issues
- Verify recipient phone number format (+1234567890)
- Check if recipient has WhatsApp installed
- Ensure business number is verified

### Webhook Issues
- URL must be publicly accessible (use ngrok for testing)
- Must use HTTPS (not HTTP)
- Verify token must match exactly

## 📚 Next Steps

After running this example successfully:

1. **Integrate into your app** - Copy the patterns into your own project
2. **Set up production infrastructure** - Deploy webhook server to cloud
3. **Create business templates** - For professional messaging
4. **Implement error handling** - For production reliability
5. **Add analytics** - Track message performance

## 🔗 Useful Links

- [WhatsApp Cloud API Documentation](https://developers.facebook.com/docs/whatsapp/cloud-api)
- [Meta Developer Console](https://developers.facebook.com/apps/)
- [Meta Business Manager](https://business.facebook.com/)
- [Package Documentation](https://pub.dev/packages/whatsapp_cloud_flutter)

## 💡 Pro Tips

- Start with Meta's test phone numbers before using production
- Use ngrok for local webhook testing
- Create templates in UTILITY category for higher approval rates
- Monitor API quotas to avoid rate limiting
- Implement message queuing for high-volume scenarios

---

**Need help?** Check the main package README or open an issue on GitHub!

**Developed by [Israel Biselu](https://github.com/israelbiselu) from [SwahiliConnect](https://swahiliconnect.com)**
