import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Security utilities for WhatsApp Cloud API.
class SecurityUtils {
  /// Verifies webhook signature to ensure request is from Meta.
  /// 
  /// [payload] is the raw webhook payload
  /// [signature] is the X-Hub-Signature-256 header value
  /// [appSecret] is your Meta app secret
  static bool verifyWebhookSignature(
    String payload,
    String signature,
    String appSecret,
  ) {
    // Remove 'sha256=' prefix if present
    final cleanSignature = signature.startsWith('sha256=') 
        ? signature.substring(7) 
        : signature;
    
    // Calculate expected signature
    final key = utf8.encode(appSecret);
    final bytes = utf8.encode(payload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    final expectedSignature = digest.toString();
    
    // Compare signatures securely
    return _secureCompare(cleanSignature, expectedSignature);
  }
  
  /// Secure string comparison to prevent timing attacks.
  static bool _secureCompare(String a, String b) {
    if (a.length != b.length) return false;
    
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    
    return result == 0;
  }
  
  /// Validates phone number format.
  static bool isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except +
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Must start with + and have 10-15 digits
    final regex = RegExp(r'^\+[1-9]\d{9,14}$');
    return regex.hasMatch(cleanNumber);
  }
  
  /// Sanitizes input to prevent injection attacks.
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'[<>"&]'), '') // Remove potential harmful chars
        .trim()
        .substring(0, input.length > 1000 ? 1000 : input.length); // Limit length
  }
}
