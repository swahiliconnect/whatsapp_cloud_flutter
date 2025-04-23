import 'dart:convert';

/// Utility class for formatting data for WhatsApp Cloud API.
class Formatters {
  /// Formats a phone number for WhatsApp API.
  ///
  /// [phoneNumber] is the phone number to format.
  /// Returns a normalized phone number.
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digits except the + sign
    String normalized = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure it has a + prefix if it doesn't start with one
    if (!normalized.startsWith('+')) {
      normalized = '+$normalized';
    }
    
    return normalized;
  }

  /// Formats a timestamp for display.
  ///
  /// [timestamp] is the timestamp to format.
  /// [includeTime] determines whether to include the time component.
  /// Returns a formatted timestamp string.
  static String formatTimestamp(
    DateTime timestamp, {
    bool includeTime = true,
  }) {
    final date = '${timestamp.year}-${_padZero(timestamp.month)}-${_padZero(timestamp.day)}';
    
    if (!includeTime) {
      return date;
    }
    
    final time =
        '${_padZero(timestamp.hour)}:${_padZero(timestamp.minute)}:${_padZero(timestamp.second)}';
    
    return '$date $time';
  }

  /// Pads a number with a leading zero if it's less than 10.
  static String _padZero(int number) {
    return number < 10 ? '0$number' : number.toString();
  }

  /// Formats a currency amount for display.
  ///
  /// [amount] is the amount in the smallest currency unit.
  /// [currencyCode] is the ISO 4217 currency code.
  /// Returns a formatted currency string.
  static String formatCurrency(int amount, String currencyCode) {
    // Simple formatter that handles common currencies
    switch (currencyCode) {
      case 'USD':
      case 'EUR':
      case 'GBP':
      case 'CAD':
      case 'AUD':
        return '${amount / 100.0} $currencyCode';
      case 'JPY':
      case 'KRW':
        return '$amount $currencyCode';
      default:
        return '${amount / 100.0} $currencyCode';
    }
  }

  /// Formats a JSON object for pretty printing.
  ///
  /// [jsonObject] is the JSON object to format.
  /// Returns a formatted JSON string.
  static String formatJson(Map<String, dynamic> jsonObject) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonObject);
  }

  /// Truncates a string to a maximum length with ellipsis.
  ///
  /// [text] is the text to truncate.
  /// [maxLength] is the maximum length.
  /// Returns a truncated string.
  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Formats a file size for display.
  ///
  /// [sizeInBytes] is the file size in bytes.
  /// Returns a formatted file size string.
  static String formatFileSize(int sizeInBytes) {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;
    
    if (sizeInBytes >= gb) {
      return '${(sizeInBytes / gb).toStringAsFixed(2)} GB';
    }
    
    if (sizeInBytes >= mb) {
      return '${(sizeInBytes / mb).toStringAsFixed(2)} MB';
    }
    
    if (sizeInBytes >= kb) {
      return '${(sizeInBytes / kb).toStringAsFixed(2)} KB';
    }
    
    return '$sizeInBytes bytes';
  }

  /// Sanitizes text for use in WhatsApp messages.
  ///
  /// [text] is the text to sanitize.
  /// Returns sanitized text.
  static String sanitizeText(String text) {
    // Remove control characters that might cause issues
    return text.replaceAll(RegExp(r'[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]'), '');
  }

  /// Private constructor to prevent instantiation
  Formatters._();
}