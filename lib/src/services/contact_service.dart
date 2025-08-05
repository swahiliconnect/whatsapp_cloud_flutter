import '../client/api_client.dart';
import '../exceptions/message_exception.dart';
import '../models/contacts/contact.dart';
import '../utils/logger.dart';

/// Service for managing WhatsApp contacts and recipient information.
class ContactService {
  /// API client for making requests
  // TODO: Implement API client usage for future features
  // ignore: unused_field
  final ApiClient _apiClient;

  /// Phone number ID for operations  
  // TODO: Implement phone number ID usage for future features
  // ignore: unused_field
  final String _phoneNumberId;

  /// Logger for contact service events
  final Logger _logger;

  /// Creates a new contact service.
  ///
  /// [apiClient] is the API client for making requests.
  /// [phoneNumberId] is the WhatsApp Business Account phone number ID.
  /// [logger] is used for logging contact service events.
  ContactService({
    required ApiClient apiClient,
    required String phoneNumberId,
    required Logger logger,
  })  : _apiClient = apiClient,
        _phoneNumberId = phoneNumberId,
        _logger = logger {
    _logger.debug('ContactService initialized');
  }

  /// Validates a phone number format for WhatsApp.
  ///
  /// [phoneNumber] is the phone number to validate.
  /// Returns true if the phone number is valid, false otherwise.
  bool isValidPhoneNumber(String phoneNumber) {
    // Basic validation: remove non-digits and check length
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Phone number should have at least country code and 7 digits
    if (digits.length < 8) return false;
    
    // Should start with + or country code
    if (!digits.startsWith('+') && !RegExp(r'^[1-9]').hasMatch(digits)) {
      return false;
    }
    
    return true;
  }

  /// Normalizes a phone number for WhatsApp API.
  ///
  /// [phoneNumber] is the phone number to normalize.
  /// Returns a normalized phone number.
  String normalizePhoneNumber(String phoneNumber) {
    // Remove all non-digits except the + sign
    String normalized = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure it has a + prefix if it doesn't start with one
    if (!normalized.startsWith('+')) {
      normalized = '+$normalized';
    }
    
    return normalized;
  }

  /// Checks if a phone number is registered on WhatsApp.
  ///
  /// [phoneNumber] is the phone number to check.
  /// Returns true if the phone number is registered, false otherwise.
  Future<bool> isRegisteredOnWhatsApp(String phoneNumber) async {
    _logger.info('Checking if phone number is registered on WhatsApp: $phoneNumber');
    
    try {
      if (!isValidPhoneNumber(phoneNumber)) {
        throw MessageException.invalidRecipient('Invalid phone number format');
      }
      
      // TODO: Use normalized phone number when API client integration is implemented
      // ignore: unused_local_variable
      final normalized = normalizePhoneNumber(phoneNumber);
      
      // The WhatsApp API currently doesn't provide a direct way to check if a number
      // is registered. However, we can use the contacts endpoint when available.
      // This is a placeholder for future implementation.
      
      // For now, assuming the number is registered if it passes validation
      _logger.warning('WhatsApp API does not provide a direct way to check if a number is registered');
      return true;
    } catch (e) {
      if (e is MessageException) rethrow;
      
      _logger.error('Failed to check if phone number is registered', e);
      throw MessageException(
        code: 'check_registration_error',
        message: 'Failed to check if phone number is registered: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Gets contact information from a phone number.
  ///
  /// [phoneNumber] is the phone number to look up.
  /// Returns a contact object if found.
  Future<Contact?> getContactInfo(String phoneNumber) async {
    _logger.info('Getting contact info for: $phoneNumber');
    
    try {
      if (!isValidPhoneNumber(phoneNumber)) {
        throw MessageException.invalidRecipient('Invalid phone number format');
      }
      
      // TODO: Use normalized phone number when API client integration is implemented
      // ignore: unused_local_variable
      final normalized = normalizePhoneNumber(phoneNumber);
      
      // The WhatsApp API currently doesn't provide a direct way to get contact info
      // This is a placeholder for future implementation.
      
      _logger.warning('WhatsApp API does not provide a direct way to get contact information');
      return null;
    } catch (e) {
      if (e is MessageException) rethrow;
      
      _logger.error('Failed to get contact info', e);
      throw MessageException(
        code: 'get_contact_info_error',
        message: 'Failed to get contact info: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Gets the profile name for a phone number.
  ///
  /// [phoneNumber] is the phone number to look up.
  /// Returns the profile name if available, null otherwise.
  Future<String?> getProfileName(String phoneNumber) async {
    _logger.info('Getting profile name for: $phoneNumber');
    
    try {
      if (!isValidPhoneNumber(phoneNumber)) {
        throw MessageException.invalidRecipient('Invalid phone number format');
      }
      
      // TODO: Use normalized phone number when API client integration is implemented
      // ignore: unused_local_variable
      final normalized = normalizePhoneNumber(phoneNumber);
      
      // The WhatsApp API currently doesn't provide a direct way to get profile name
      // This is a placeholder for future implementation.
      
      _logger.warning('WhatsApp API does not provide a direct way to get profile name');
      return null;
    } catch (e) {
      if (e is MessageException) rethrow;
      
      _logger.error('Failed to get profile name', e);
      throw MessageException(
        code: 'get_profile_name_error',
        message: 'Failed to get profile name: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Builds a full contact object.
  ///
  /// [firstName] is the first name.
  /// [lastName] is the last name.
  /// [phoneNumber] is the phone number.
  /// [email] is an optional email address.
  /// Returns a complete contact object.
  Contact buildContact({
    required String firstName,
    String? lastName,
    required String phoneNumber,
    String? email,
  }) {
    if (!isValidPhoneNumber(phoneNumber)) {
      throw MessageException.invalidRecipient('Invalid phone number format');
    }
    
    final phones = [
      Phone(phone: phoneNumber),
    ];
    
    final emails = email != null && email.isNotEmpty
        ? [Email(email: email)]
        : <Email>[];
    
    return Contact(
      firstName: firstName,
      lastName: lastName,
      phones: phones,
      emails: emails,
    );
  }
}