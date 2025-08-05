import '../exceptions/message_exception.dart';
import '../models/messages/message.dart';

/// Utility class for validating WhatsApp-related data.
class Validators {
  /// Validates a phone number format for WhatsApp.
  ///
  /// [phoneNumber] is the phone number to validate.
  /// Returns true if the phone number is valid.
  /// Throws [MessageException] if the phone number is invalid.
  static bool validatePhoneNumber(String phoneNumber) {
    // Basic validation: remove non-digits and check length
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Phone number should have at least country code and 7 digits
    if (digits.length < 8) {
      throw MessageException.invalidRecipient(
        'Phone number is too short. It should include country code and at least 7 digits.',
      );
    }
    
    // Should start with + or country code
    if (!digits.startsWith('+') && !RegExp(r'^[1-9]').hasMatch(digits)) {
      throw MessageException.invalidRecipient(
        'Phone number should start with a + sign or a valid country code.',
      );
    }
    
    return true;
  }

  /// Validates text message content.
  ///
  /// [text] is the text content to validate.
  /// Returns true if the text is valid.
  /// Throws [MessageException] if the text is invalid.
  static bool validateTextContent(String text) {
    if (text.isEmpty) {
      throw MessageException.invalidContent('Message text cannot be empty.');
    }
    
    if (text.length > 4096) {
      throw MessageException.invalidContent(
        'Message text exceeds maximum length of 4096 characters.',
      );
    }
    
    return true;
  }

  /// Validates media URL format.
  ///
  /// [url] is the media URL to validate.
  /// Returns true if the URL is valid.
  /// Throws [MessageException] if the URL is invalid.
  static bool validateMediaUrl(String url) {
    if (url.isEmpty) {
      throw MessageException.invalidContent('Media URL cannot be empty.');
    }
    
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw MessageException.invalidContent('Invalid media URL format.');
    }
    
    // Must be HTTPS except for development environments
    if (uri.scheme != 'https' && uri.host != 'localhost' && !uri.host.startsWith('192.168.')) {
      throw MessageException.invalidContent('Media URL must use HTTPS protocol.');
    }
    
    return true;
  }

  /// Validates template name format.
  ///
  /// [templateName] is the template name to validate.
  /// Returns true if the template name is valid.
  /// Throws [MessageException] if the template name is invalid.
  static bool validateTemplateName(String templateName) {
    if (templateName.isEmpty) {
      throw MessageException.invalidContent('Template name cannot be empty.');
    }
    
    // Template names should be alphanumeric with underscores
    final RegExp validNamePattern = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!validNamePattern.hasMatch(templateName)) {
      throw MessageException.invalidContent(
        'Template name should only contain letters, numbers, and underscores.',
      );
    }
    
    return true;
  }

  /// Validates language code format.
  ///
  /// [languageCode] is the language code to validate.
  /// Returns true if the language code is valid.
  /// Throws [MessageException] if the language code is invalid.
  static bool validateLanguageCode(String languageCode) {
    if (languageCode.isEmpty) {
      throw MessageException.invalidContent('Language code cannot be empty.');
    }
    
    // Basic format check (en_US, pt_BR, etc.)
    final RegExp validCodePattern = RegExp(r'^[a-z]{2}(_[A-Z]{2})?$');
    if (!validCodePattern.hasMatch(languageCode)) {
      throw MessageException.invalidContent(
        'Language code should be in format "xx" or "xx_YY".',
      );
    }
    
    return true;
  }

  /// Validates geographic coordinates.
  ///
  /// [latitude] is the latitude coordinate.
  /// [longitude] is the longitude coordinate.
  /// Returns true if the coordinates are valid.
  /// Throws [MessageException] if the coordinates are invalid.
  static bool validateCoordinates(double latitude, double longitude) {
    if (latitude < -90 || latitude > 90) {
      throw MessageException.invalidContent(
        'Latitude must be between -90 and 90 degrees.',
      );
    }
    
    if (longitude < -180 || longitude > 180) {
      throw MessageException.invalidContent(
        'Longitude must be between -180 and 180 degrees.',
      );
    }
    
    return true;
  }

  /// Validates a message object before sending.
  ///
  /// [message] is the message to validate.
  /// Returns true if the message is valid.
  /// Throws [MessageException] if the message is invalid.
  static bool validateMessage(Message message) {
    // Validate recipient
    validatePhoneNumber(message.recipient);
    
    // Check if message content is valid according to its type
    if (!message.isValid()) {
      throw MessageException.invalidContent(
        'Invalid message content for type ${message.type}.',
      );
    }
    
    return true;
  }

  /// Private constructor to prevent instantiation
  Validators._();
}