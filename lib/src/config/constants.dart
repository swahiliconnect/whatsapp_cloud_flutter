/// Constants used throughout the WhatsApp Cloud API client.
class Constants {
  /// Base URL for the WhatsApp Cloud API
  static const String apiBaseUrl = 'https://graph.facebook.com/v16.0';

  /// Headers used in API requests
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// API version path component
  static const String apiVersion = 'v16.0';

  /// Default timeout duration for API requests in seconds
  static const int defaultTimeoutSeconds = 30;

  /// Maximum retries for failed API requests
  static const int maxRetries = 3;

  /// Rate limit for WhatsApp Cloud API (requests per minute)
  static const int rateLimit = 80;

  /// Maximum file size for media uploads in bytes (16MB)
  static const int maxMediaSizeBytes = 16 * 1024 * 1024;

  /// Supported media types
  static const List<String> supportedMediaTypes = [
    'image/jpeg',
    'image/png',
    'application/pdf',
    'audio/mp3',
    'audio/aac',
    'video/mp4',
  ];

  /// Base path for media endpoints
  static const String mediaPath = 'media';

  /// Base path for message endpoints
  static const String messagePath = 'messages';

  /// Base path for template endpoints
  static const String templatePath = 'message_templates';

  /// Package version
  static const String packageVersion = '1.1.3';

  /// Package name
  static const String packageName = 'whatsapp_cloud_flutter';

  /// Private constructor to prevent instantiation
  Constants._();
}