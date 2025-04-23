# Changelog

All notable changes to the `whatsapp_cloud_flutter` package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-04-23

### Added
- Initial release of the WhatsApp Cloud Flutter package
- Core functionality for interacting with the WhatsApp Cloud API
- Authentication and token management
- Message services for sending various message types:
  - Text messages
  - Media messages (image, video, audio, document, sticker)
  - Interactive messages (buttons, lists)
  - Location messages
  - Contact messages
  - Template messages
- Template management services
- Media upload and download services
- Webhook handling for incoming messages and status updates
- Error handling and retry mechanisms
- Rate limiting to prevent API quota issues
- Comprehensive logging for debugging and monitoring
- Flutter UI components:
  - MessageComposer widget
  - TemplateSelector widget
  - ChatBubble widget
- Example applications demonstrating all major features
- Comprehensive documentation with usage examples