import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Types of WhatsApp messages supported by the API.
enum MessageType {
  /// Text message with plain text content
  text,

  /// Image message with caption support
  image,

  /// Video message with optional caption
  video,

  /// Audio message
  audio,

  /// Document message with filename and caption
  document,

  /// Sticker message
  sticker,

  /// Location message with coordinates
  location,

  /// Contact message with contact information
  contacts,

  /// Interactive message with buttons or lists
  interactive,

  /// Template message following a predefined structure
  template,

  /// Reaction to a previous message
  reaction,

  /// Address request message - allows requesting delivery address from users
  address,

  /// Interactive Call-To-Action URL message
  ctaUrl,

  /// Interactive Flow message - for complex structured interactions
  flow,

  /// Interactive location request message
  locationRequest,

  /// Order message - for commerce/shopping features
  order,

  /// System message - for automated system notifications
  system,
}

/// Base class for all WhatsApp message types.
///
/// This abstract class defines the common structure and behavior
/// for all message types supported by the WhatsApp Cloud API.
@immutable
abstract class Message extends Equatable {
  /// The type of message
  final MessageType type;

  /// Recipient's phone number in international format
  final String recipient;

  /// Creates a new message instance.
  ///
  /// [type] specifies the type of message.
  /// [recipient] is the recipient's phone number in international format.
  const Message({
    required this.type,
    required this.recipient,
  });

  /// Validates the message content before sending.
  ///
  /// Implementations should check for required fields and format.
  /// Returns true if the message is valid, false otherwise.
  bool isValid();

  /// Converts the message to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson();

  /// Creates a base message map with common properties.
  ///
  /// This is used as a starting point for all message types.
  /// Returns a map with the recipient information.
  @protected
  Map<String, dynamic> createBaseMessageMap() {
    return {
      'messaging_product': 'whatsapp',
      'recipient_type': 'individual',
      'to': recipient,
    };
  }

  @override
  List<Object?> get props => [type, recipient];
}