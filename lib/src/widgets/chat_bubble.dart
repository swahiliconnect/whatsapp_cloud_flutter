import 'package:flutter/material.dart';

/// Alignment options for chat bubbles.
enum BubbleAlignment {
  /// Left-aligned bubble (for received messages)
  left,

  /// Right-aligned bubble (for sent messages)
  right,
}

/// A widget for displaying a chat message bubble.
class ChatBubble extends StatelessWidget {
  /// The text message to display
  final String message;

  /// The sender's name (optional)
  final String? senderName;

  /// Timestamp for the message (optional)
  final DateTime? timestamp;

  /// Alignment of the bubble
  final BubbleAlignment alignment;

  /// Status of the message (optional)
  final String? status;

  /// Custom text style for the message
  final TextStyle? textStyle;

  /// Custom background color for the bubble
  final Color? backgroundColor;

  /// Creates a new chat bubble widget.
  ///
  /// [message] is the text message to display.
  /// [senderName] is an optional sender name to show above the bubble.
  /// [timestamp] is an optional timestamp to show below the bubble.
  /// [alignment] determines whether the bubble is left or right-aligned.
  /// [status] is an optional status indicator (e.g., "delivered", "read").
  /// [textStyle] is the text style for the message.
  /// [backgroundColor] is the background color for the bubble.
  const ChatBubble({
    Key? key,
    required this.message,
    this.senderName,
    this.timestamp,
    this.alignment = BubbleAlignment.left,
    this.status,
    this.textStyle,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isReceived = alignment == BubbleAlignment.left;

    // Default colors and styles based on alignment
    final bubbleColor = backgroundColor ??
        (isReceived
            ? Colors.grey.shade200
            : Theme.of(context).colorScheme.primary);

    final messageStyle = textStyle ??
        (isReceived
            ? const TextStyle(color: Colors.black)
            : const TextStyle(color: Colors.white));

    final timeStyle = TextStyle(
      color: isReceived ? Colors.black54 : Colors.white70,
      fontSize: 12.0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment:
            isReceived ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (senderName != null && isReceived)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
              child: Text(
                senderName!,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18.0),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Text(
              message,
              style: messageStyle,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (timestamp != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 12.0, right: 4.0),
                  child: Text(
                    _formatTime(timestamp!),
                    style: timeStyle,
                  ),
                ),
              if (status != null && !isReceived)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                  child: Text(
                    status!,
                    style: timeStyle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formats the timestamp for display.
  String _formatTime(DateTime time) {
    return '${_padZero(time.hour)}:${_padZero(time.minute)}';
  }

  /// Pads a number with a leading zero if it's less than 10.
  String _padZero(int number) {
    return number < 10 ? '0$number' : number.toString();
  }
}

/// A widget for displaying a chat conversation with multiple bubbles.
class ChatConversation extends StatelessWidget {
  /// List of messages to display
  final List<ChatBubbleData> messages;

  /// Callback when a message is tapped
  final Function(ChatBubbleData message)? onMessageTap;

  /// Creates a new chat conversation widget.
  ///
  /// [messages] is the list of messages to display.
  /// [onMessageTap] is an optional callback when a message is tapped.
  const ChatConversation({
    Key? key,
    required this.messages,
    this.onMessageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: messages.length,
      reverse: true,
      itemBuilder: (context, index) {
        final msg = messages[index];
        
        return GestureDetector(
          onTap: () => onMessageTap?.call(msg),
          child: ChatBubble(
            message: msg.message,
            senderName: msg.senderName,
            timestamp: msg.timestamp,
            alignment: msg.alignment,
            status: msg.status,
            backgroundColor: msg.backgroundColor,
            textStyle: msg.textStyle,
          ),
        );
      },
    );
  }
}


/// Data class for chat bubble information.
class ChatBubbleData {
  /// The text message to display
  final String message;

  /// The sender's name (optional)
  final String? senderName;

  /// Timestamp for the message
  final DateTime timestamp;

  /// Alignment of the bubble
  final BubbleAlignment alignment;

  /// Status of the message (optional)
  final String? status;

  /// Custom background color for the bubble
  final Color? backgroundColor;

  /// Custom text style for the message
  final TextStyle? textStyle;

  /// Message ID (optional)
  final String? messageId;

  /// Creates a new chat bubble data object.
  ///
  /// [message] is the text message to display.
  /// [timestamp] is the timestamp of the message.
  /// [alignment] determines whether the bubble is left or right-aligned.
  /// [senderName] is an optional sender name to show above the bubble.
  /// [status] is an optional status indicator (e.g., "delivered", "read").
  /// [backgroundColor] is a custom background color for the bubble.
  /// [textStyle] is a custom text style for the message.
  /// [messageId] is an optional message ID for reference.
  const ChatBubbleData({
    required this.message,
    required this.timestamp,
    required this.alignment,
    this.senderName,
    this.status,
    this.backgroundColor,
    this.textStyle,
    this.messageId,
  });
}