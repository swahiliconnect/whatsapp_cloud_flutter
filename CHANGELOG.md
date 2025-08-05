# Changelog

All notable changes to the `whatsapp_cloud_flutter` package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.3] - 2025-08-05

### 🐛 Critical Bug Fixes

#### URL Construction Fix
- **Fixed HTTP 400 errors** - Resolved incorrect API endpoint URL construction that was causing all message sending to fail
- **Proper slash handling** - Added missing leading slashes to all API endpoints to ensure correct URL formation
- **Fixed endpoints affected:**
  - Message Service: All message sending methods (text, media, templates, reactions, etc.)
  - Media Service: Media upload and URL-based media sending
  - Template Service: Template creation, retrieval, and management
- **Before**: `https://graph.facebook.com/v16.0111605711818262/messages` ❌
- **After**: `https://graph.facebook.com/v16.0/111605711818262/messages` ✅

#### Impact
- **Resolves all HTTP 400 "Client error" responses** when sending messages
- **Fixes WhatsApp Cloud API communication** for all package functionality
- **No breaking changes** - existing code will work immediately after update

### 🔧 Technical Details
- Updated endpoint construction in `MessageService`, `MediaService`, and `TemplateService`
- Removed duplicate API version prefixes in template endpoints
- Ensured consistent URL formatting across all services

## [1.1.2] - 2025-08-05

### 📚 Documentation Improvements

#### Enhanced Example Code
- **Complete webhook server example** - Added full webhook server implementation as commented code in example/lib/main.dart
- **Copy-paste ready code** - Users can now easily copy the complete working webhook server from the example
- **Detailed setup instructions** - Step-by-step guide for running webhook servers in pure Dart environments
- **Production-ready template** - Includes CORS, error handling, auto-reply functionality, and proper logging

#### Developer Experience
- **Improved accessibility** - Webhook server code now available in both standalone file and commented in main example
- **Clear documentation** - Better explanation of server vs Flutter client differences
- **Setup guidance** - Complete instructions for ngrok, Meta Developer Console configuration

## [1.1.1] - 2025-08-05

### 🔧 Bug Fixes

#### Server Compatibility
- **Fixed Flutter UI dependency issue** - Resolved "dart:ui library is not available on this platform" error when running webhook servers in pure Dart environments
- **Added server-compatible exports** - Created `whatsapp_cloud_server.dart` library export that excludes Flutter UI dependencies
- **Server-only authentication manager** - Implemented `ServerAuthManager` with in-memory token storage to replace SharedPreferences in server environments
- **Pure Dart client implementation** - Added `WhatsAppCloudServerClient` for server-side WhatsApp API integration without Flutter dependencies

#### Architecture Improvements
- **Introduced authentication interface** - Created `AuthManagerInterface` to allow both Flutter and server authentication managers
- **Dependency isolation** - Separated Flutter-specific imports from core API functionality
- **Improved import structure** - Cleaned up service imports to avoid circular dependencies with Flutter UI components

### 🚀 New Features
- **Server webhook example** - Added `webhook_server_simple.dart` with production-ready server implementation
- **In-memory token storage** - Server-compatible token storage that doesn't require Flutter's SharedPreferences
- **Simplified server setup** - One-step server client creation for webhook implementations

### 📚 Documentation Updates
- Updated webhook server examples to use server-compatible client
- Added server deployment guidance
- Clarified Flutter vs pure Dart environment requirements

## [1.1.0] - 2025-08-05

### 🚀 Major Documentation & Integration Update

This release significantly improves the developer experience with comprehensive implementation guides and production-ready examples.

### ✨ Features Added

#### Complete Implementation Guides
- **Webhook Server Implementation** - Production-ready webhook server with auto-reply functionality
- **Media Upload Examples** - Complete integration with Flutter's image_picker and file_picker
- **Template Management Guide** - Step-by-step template creation and approval workflow
- **First-Time User Setup** - Comprehensive checklist and troubleshooting guide

#### Enhanced Example Application
- **Detailed Code Comments** - Complete implementation examples in comments
- **Webhook Server Example** - Ready-to-run webhook server (`webhook_server.dart`)
- **Media Upload Integration** - Working examples for camera, gallery, and file uploads
- **Template Usage Examples** - Business template implementation patterns
- **Enhanced Documentation** - Complete setup guide for new users

#### Developer Experience Improvements
- **README Enhancement** - Added collapsible implementation guides
- **Example README** - Complete first-time user guide with troubleshooting
- **Dependency Management** - Clear optional dependencies with usage instructions
- **Setup Checklists** - Step-by-step validation for all features

#### Production Ready Components
- **Complete Webhook Server** - CORS support, error handling, auto-replies
- **Security Best Practices** - Token management, input validation, webhook verification
- **Configuration Examples** - Development vs production environment setup
- **Debugging Tools** - Enhanced logging and error reporting

### 📚 Documentation Improvements
- Complete webhook server implementation with setup instructions
- Media upload integration with Flutter image picker
- Template management workflow with Meta Business Manager
- First-time setup checklist with common issues and solutions
- Production deployment security guidelines
- Enhanced troubleshooting section with solutions

### 🔧 Developer Tools
- Production-ready webhook server example
- Media upload manager with multiple sources (camera, gallery, files, URLs)
- Template manager with approval workflow
- Configuration examples for different environments
- Debugging utilities and logging enhancements

### 📱 Example Application Updates
- Enhanced UI with better user experience
- Complete implementation examples in comments
- Optional dependency management
- Step-by-step setup instructions
- Real-world usage patterns

## [1.0.0] - 2025-05-24

### 🎉 Initial Release

The first stable release of WhatsApp Cloud Flutter package, providing comprehensive WhatsApp Cloud API integration for Flutter applications.

### ✨ Features Added

#### Core Functionality
- **WhatsApp Cloud Client** - Complete client implementation with configuration options
- **Authentication Management** - Secure token handling and validation
- **Environment Configuration** - Support for production and sandbox environments
- **Comprehensive Error Handling** - Specific exception types for different error scenarios

#### Message Services
- **Text Messages** - Send rich text messages with URL preview support
- **Media Messages** - Support for images, videos, audio, documents, and stickers
- **Interactive Messages** - Button and list-based interactive messages
- **Advanced Interactive Messages** - CTA URLs, location requests, address collection
- **Location Messages** - Send GPS coordinates with names and addresses
- **Contact Messages** - Share vCard format contact information
- **Template Messages** - Business template support with dynamic parameters
- **Reaction Messages** - Emoji reactions to messages
- **Message Status Tracking** - Mark messages as read, track delivery status

#### Advanced Features
- **Rate Limiting** - Built-in protection against API quota violations
- **Retry Mechanism** - Automatic retry with exponential backoff
- **Comprehensive Logging** - Multi-level logging for debugging and monitoring
- **Analytics Integration** - Performance metrics and usage analytics
- **Security Features** - Input validation, webhook signature verification
- **Webhook Integration** - Complete webhook handling for real-time events

#### Flutter UI Components
- **MessageComposer** - Ready-to-use message input widget
- **TemplateSelector** - Template picker with preview functionality
- **ChatBubble** - Customizable message bubble widget

#### Developer Experience
- **Type Safety** - Full type safety for all API interactions
- **Comprehensive Documentation** - Detailed API documentation and examples
- **Example Application** - Complete working example demonstrating all features
- **Unit Tests** - Comprehensive test coverage

### 📚 Documentation & Examples
- Complete README with step-by-step usage guide
- API reference documentation
- Production deployment security checklist
- Comprehensive example application
- Contributing guidelines

### 🛡️ Security & Production Ready
- Webhook signature verification
- Secure token management
- Input validation and sanitization
- Comprehensive error handling
- Rate limiting protection

### 📊 Platform Support
- Android, iOS, Web, Windows, macOS, Linux

**Author**: Israel Biselu from SwahiliConnect  
**License**: MIT License