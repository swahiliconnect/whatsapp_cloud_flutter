import 'src/auth/server_auth_manager.dart';
import 'src/client/api_client.dart';
import 'src/config/api_config.dart';
import 'src/services/message_service.dart';
import 'src/services/template_service.dart';
import 'src/services/media_service.dart';
import 'src/services/contact_service.dart';
import 'src/services/webhook_service.dart';
import 'src/utils/logger.dart';

/// Server-compatible WhatsApp Cloud API client.
///
/// This client is designed for server/CLI environments and doesn't depend
/// on Flutter UI components. It uses in-memory token storage instead of
/// SharedPreferences.
class WhatsAppCloudServerClient {
  /// WhatsApp Business Account Phone Number ID
  final String phoneNumberId;

  /// Meta WhatsApp API Access Token
  final String accessToken;

  /// API Configuration object, defaults to standard production settings
  final WhatsAppApiConfig config;

  /// Authentication manager for token management
  late final ServerAuthManager _authManager;

  /// Core API client for making HTTP requests
  late final ApiClient _apiClient;

  /// Service for sending and receiving messages
  late final MessageService _messageService;

  /// Service for managing message templates
  late final TemplateService _templateService;

  /// Service for handling media uploads and downloads
  late final MediaService _mediaService;

  /// Service for managing contacts
  late final ContactService _contactService;

  /// Service for processing webhook notifications
  late final WebhookService _webhookService;

  /// Logger instance for internal logging
  late final Logger _logger;

  /// Creates a new WhatsApp Cloud API server client.
  ///
  /// [phoneNumberId] is the WhatsApp Business Account phone number ID.
  /// [accessToken] is the authentication token for the API.
  /// [config] provides optional custom configuration settings.
  WhatsAppCloudServerClient({
    required this.phoneNumberId,
    required this.accessToken,
    WhatsAppApiConfig? config,
  }) : config = config ?? const WhatsAppApiConfig() {
    _logger = Logger(level: this.config.logLevel);
    _logger.info('Initializing WhatsAppCloudServerClient');

    // Use in-memory token storage for server environments
    final tokenStorage = ServerInMemoryTokenStorage(logger: _logger);

    _authManager = ServerAuthManager(
      accessToken: accessToken,
      tokenStorage: tokenStorage,
      logger: _logger,
    );

    _apiClient = ApiClient(
      baseUrl: this.config.baseUrl,
      authManager: _authManager,
      logger: _logger,
      connectTimeout: this.config.connectTimeout,
      receiveTimeout: this.config.receiveTimeout,
      retryPolicy: this.config.retryPolicy,
    );

    _messageService = MessageService(
      apiClient: _apiClient,
      phoneNumberId: phoneNumberId,
      logger: _logger,
    );

    _templateService = TemplateService(
      apiClient: _apiClient,
      phoneNumberId: phoneNumberId,
      logger: _logger,
    );

    _mediaService = MediaService(
      apiClient: _apiClient,
      phoneNumberId: phoneNumberId,
      logger: _logger,
    );

    _contactService = ContactService(
      apiClient: _apiClient,
      phoneNumberId: phoneNumberId,
      logger: _logger,
    );

    _webhookService = WebhookService(
      logger: _logger,
    );

    _logger.info('WhatsAppCloudServerClient initialized successfully');
  }

  /// Service for sending messages
  MessageService get messageService => _messageService;

  /// Service for managing message templates
  TemplateService get templateService => _templateService;

  /// Service for handling media operations
  MediaService get mediaService => _mediaService;

  /// Service for managing contacts
  ContactService get contactService => _contactService;

  /// Service for processing webhook notifications
  WebhookService get webhookService => _webhookService;

  /// Logger instance for debugging and monitoring
  Logger get logger => _logger;

  /// Disposes of the client and cleans up resources
  void dispose() {
    _logger.info('Disposing WhatsAppCloudServerClient');
    // Cleanup if needed in the future
  }
}