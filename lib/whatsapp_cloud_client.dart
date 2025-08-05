import 'package:meta/meta.dart';

import 'src/auth/auth_manager.dart';
import 'src/auth/auth_interface.dart';
import 'src/client/api_client.dart';
import 'src/config/api_config.dart';
import 'src/config/environment.dart';
import 'src/services/message_service.dart';
import 'src/services/template_service.dart';
import 'src/services/media_service.dart';
import 'src/services/contact_service.dart';
import 'src/services/webhook_service.dart';
import 'src/utils/logger.dart';

/// The main client class for interacting with WhatsApp Cloud API.
///
/// This class serves as the entry point for utilizing all WhatsApp Cloud API
/// features including messaging, templates, media sharing, and webhook handling.
class WhatsAppCloudClient {
  /// WhatsApp Business Account Phone Number ID
  final String phoneNumberId;

  /// Meta WhatsApp API Access Token
  final String accessToken;

  /// API Configuration object, defaults to standard production settings
  final WhatsAppApiConfig config;

  /// Authentication manager for token management
  late final AuthManagerInterface _authManager;

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

  /// Creates a new WhatsApp Cloud API client.
  ///
  /// [phoneNumberId] is the WhatsApp Business Account phone number ID.
  /// [accessToken] is the authentication token for the API.
  /// [environment] specifies the API environment (production/sandbox).
  /// [config] provides optional custom configuration settings.
  WhatsAppCloudClient({
    required this.phoneNumberId,
    required this.accessToken,
    Environment environment = Environment.production,
    WhatsAppApiConfig? config,
  }) : config = config ?? WhatsAppApiConfig(environment: environment) {
    _logger = Logger(level: this.config.logLevel);
    _logger.info('Initializing WhatsAppCloudClient');

    _authManager = AuthManager(
      accessToken: accessToken,
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

    _logger.info('WhatsAppCloudClient initialized successfully');
  }

  /// Access to the message service for sending various message types
  MessageService get messageService => _messageService;

  /// Access to the template service for working with message templates
  TemplateService get templateService => _templateService;

  /// Access to the media service for handling media files
  MediaService get mediaService => _mediaService;

  /// Access to the contact service for managing recipients
  ContactService get contactService => _contactService;

  /// Access to the webhook service for processing incoming events
  WebhookService get webhookService => _webhookService;

  /// Internal API client for advanced usage
  @visibleForTesting
  ApiClient get apiClient => _apiClient;
}