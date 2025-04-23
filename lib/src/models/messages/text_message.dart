import 'package:meta/meta.dart';

import 'message.dart';

/// Text message implementation for WhatsApp Cloud API.
///
/// Represents a simple text message with optional URL preview.
@immutable
class TextMessage extends Message {
  /// The text content of the message
  final String text;

  /// Whether to preview URLs in the message
  final bool previewUrl;

  /// Creates a new text message.
  ///
  /// [recipient] is the recipient's phone number in international format.
  /// [text] is the content of the message (max 4096 characters).
  /// [previewUrl] determines whether URLs in the text should show a preview.
  const TextMessage({
    required String recipient,
    required this.text,
    this.previewUrl = false,
  }) : super(
          type: MessageType.text,
          recipient: recipient,
        );

  @override
  bool isValid() {
    // Check for empty or oversized content
    return text.isNotEmpty && text.length <= 4096;
  }

  @override
  Map<String, dynamic> toJson() {
    final messageMap = createBaseMessageMap();
    
    messageMap['type'] = 'text';
    messageMap['text'] = {
      'body': text,
      'preview_url': previewUrl,
    };
    
    return messageMap;
  }

  @override
  List<Object?> get props => [...super.props, text, previewUrl];

  /// Creates a copy of this message with the given fields replaced.
  TextMessage copyWith({
    String? recipient,
    String? text,
    bool? previewUrl,
  }) {
    return TextMessage(
      recipient: recipient ?? this.recipient,
      text: text ?? this.text,
      previewUrl: previewUrl ?? this.previewUrl,
    );
  }
}