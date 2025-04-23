import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

/// Utility class to manage a shared WhatsApp Cloud client instance.
class WhatsAppClientUtil {
  static WhatsAppCloudClient? _client;

  /// Initializes the WhatsApp Cloud client with the provided credentials.
  ///
  /// [phoneNumberId] is the WhatsApp Business Account phone number ID.
  /// [accessToken] is the API access token.
  /// [environment] specifies the API environment (default: production).
  static void initialize({
    required String phoneNumberId,
    required String accessToken,
    Environment environment = Environment.production,
  }) {
    _client = WhatsAppCloudClient(
      phoneNumberId: phoneNumberId,
      accessToken: accessToken,
      environment: environment,
      config: WhatsAppApiConfig(
        logLevel: LogLevel.debug,
      ),
    );
  }

  /// Gets the shared WhatsApp Cloud client instance.
  ///
  /// Throws an assertion error if the client is not initialized.
  static WhatsAppCloudClient get client {
    assert(_client != null, 'WhatsApp client is not initialized. Call initialize() first.');
    return _client!;
  }

  /// Gets the message service from the client.
  ///
  /// Throws an assertion error if the client is not initialized.
  static MessageService get messageService {
    return client.messageService;
  }

  /// Gets the template service from the client.
  ///
  /// Throws an assertion error if the client is not initialized.
  static TemplateService get templateService {
    return client.templateService;
  }

  /// Gets the media service from the client.
  ///
  /// Throws an assertion error if the client is not initialized.
  static MediaService get mediaService {
    return client.mediaService;
  }

  /// Gets the webhook service from the client.
  ///
  /// Throws an assertion error if the client is not initialized.
  static WebhookService get webhookService {
    return client.webhookService;
  }

  /// Checks if the client is initialized.
  static bool get isInitialized => _client != null;
}