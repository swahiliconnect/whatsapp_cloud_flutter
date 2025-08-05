import 'package:meta/meta.dart';
import '../messages/message.dart';

/// Interactive Call-To-Action URL message for mapping URLs to buttons.
@immutable
class CtaUrlMessage extends Message {
  /// Main body text of the message
  final String bodyText;

  /// Text displayed on the CTA button
  final String buttonText;

  /// URL that the button links to
  final String url;

  /// Optional header text
  final String? headerText;

  /// Optional footer text
  final String? footerText;

  /// Creates a new CTA URL message.
  ///
  /// [recipient] is the recipient's phone number in international format.
  /// [bodyText] is the main message text.
  /// [buttonText] is the text shown on the button.
  /// [url] is the URL to open when button is pressed.
  /// [headerText] is optional header text.
  /// [footerText] is optional footer text.
  const CtaUrlMessage({
    required String recipient,
    required this.bodyText,
    required this.buttonText,
    required this.url,
    this.headerText,
    this.footerText,
  }) : super(
          type: MessageType.ctaUrl,
          recipient: recipient,
        );

  @override
  bool isValid() {
    return bodyText.isNotEmpty &&
        bodyText.length <= 1024 &&
        buttonText.isNotEmpty &&
        buttonText.length <= 20 &&
        url.isNotEmpty &&
        Uri.tryParse(url) != null;
  }

  @override
  Map<String, dynamic> toJson() {
    final messageMap = createBaseMessageMap();
    
    messageMap['type'] = 'interactive';
    
    final interactive = <String, dynamic>{
      'type': 'cta_url',
      'body': {'text': bodyText},
      'action': {
        'name': 'cta_url',
        'parameters': {
          'display_text': buttonText,
          'url': url,
        },
      },
    };
    
    if (headerText != null && headerText!.isNotEmpty) {
      interactive['header'] = {
        'type': 'text',
        'text': headerText,
      };
    }
    
    if (footerText != null && footerText!.isNotEmpty) {
      interactive['footer'] = {'text': footerText};
    }
    
    messageMap['interactive'] = interactive;
    
    return messageMap;
  }

  @override
  List<Object?> get props => [
        ...super.props,
        bodyText,
        buttonText,
        url,
        headerText,
        footerText,
      ];
}

/// Interactive location request message to request user's location.
@immutable
class LocationRequestMessage extends Message {
  /// Main body text of the message
  final String bodyText;

  /// Creates a new location request message.
  ///
  /// [recipient] is the recipient's phone number in international format.
  /// [bodyText] is the message asking for location.
  const LocationRequestMessage({
    required String recipient,
    required this.bodyText,
  }) : super(
          type: MessageType.locationRequest,
          recipient: recipient,
        );

  @override
  bool isValid() {
    return bodyText.isNotEmpty && bodyText.length <= 1024;
  }

  @override
  Map<String, dynamic> toJson() {
    final messageMap = createBaseMessageMap();
    
    messageMap['type'] = 'interactive';
    messageMap['interactive'] = {
      'type': 'location_request_message',
      'body': {'text': bodyText},
      'action': {
        'name': 'send_location',
      },
    };
    
    return messageMap;
  }

  @override
  List<Object?> get props => [...super.props, bodyText];
}

/// Address request message for delivery address collection.
@immutable
class AddressMessage extends Message {
  /// Main body text of the message
  final String bodyText;

  /// Creates a new address request message.
  ///
  /// [recipient] is the recipient's phone number in international format.
  /// [bodyText] is the message asking for address.
  const AddressMessage({
    required String recipient,
    required this.bodyText,
  }) : super(
          type: MessageType.address,
          recipient: recipient,
        );

  @override
  bool isValid() {
    return bodyText.isNotEmpty && bodyText.length <= 1024;
  }

  @override
  Map<String, dynamic> toJson() {
    final messageMap = createBaseMessageMap();
    
    messageMap['type'] = 'interactive';
    messageMap['interactive'] = {
      'type': 'address_message',
      'body': {'text': bodyText},
      'action': {
        'name': 'address_message',
      },
    };
    
    return messageMap;
  }

  @override
  List<Object?> get props => [...super.props, bodyText];
}
