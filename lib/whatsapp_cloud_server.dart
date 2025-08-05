/// WhatsApp Cloud API Server Library
/// 
/// This library provides server-compatible WhatsApp Cloud API integration
/// without Flutter UI dependencies. Perfect for webhook servers and backend
/// applications.
/// 
/// Main differences from the Flutter version:
/// - Uses in-memory token storage instead of shared_preferences
/// - Excludes Flutter UI widgets
/// - Optimized for server/CLI environments

library whatsapp_cloud_server;

// Core client
export 'src/client/api_client.dart';

// Configuration
export 'src/config/api_config.dart';
export 'src/config/constants.dart';
export 'src/config/environment.dart';
export 'src/config/environment_config.dart';

// Services
export 'src/services/message_service.dart';
export 'src/services/template_service.dart';
export 'src/services/media_service.dart';
export 'src/services/contact_service.dart';
export 'src/services/webhook_service.dart';

// Models
export 'src/models/contacts/contact.dart';
export 'src/models/media/media_file.dart';
export 'src/models/media/media_type.dart';
export 'src/models/messages/message.dart';
export 'src/models/messages/text_message.dart';
export 'src/models/messages/media_message.dart';
export 'src/models/messages/location_message.dart';
export 'src/models/messages/interactive_message.dart';
export 'src/models/messages/advanced_interactive_message.dart';
export 'src/models/responses/message_response.dart';
export 'src/models/responses/base_response.dart';
export 'src/models/templatez/template.dart';
export 'src/models/templatez/template_component.dart';

// Authentication (server version with in-memory storage)
export 'src/auth/auth_manager.dart';
export 'src/auth/token_storage.dart' show TokenStorage, InMemoryTokenStorage;

// Utilities
export 'src/utils/logger.dart';
export 'src/utils/validators.dart';
export 'src/utils/formatters.dart';
export 'src/utils/security.dart';
export 'src/utils/analytics.dart';

// Exceptions
export 'src/exceptions/api_exception.dart';
export 'src/exceptions/auth_exception.dart';
export 'src/exceptions/message_exception.dart';
export 'src/exceptions/media_exception.dart';