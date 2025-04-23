import 'package:flutter/material.dart';

/// Alignment options for chat bubbles
enum BubbleAlignment {
  left,
  right,
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

/// Widget to display a chat conversation with multiple bubbles
class ChatConversation extends StatelessWidget {
  final List<ChatBubbleData> messages;
  final Function(ChatBubbleData)? onMessageTap;

  const ChatConversation({
    Key? key,
    required this.messages,
    this.onMessageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final message = messages[index];
        return InkWell(
          onTap: () => onMessageTap?.call(message),
          child: ChatBubble(data: message),
        );
      },
    );
  }
}

/// Widget to display a single chat bubble
class ChatBubble extends StatelessWidget {
  final ChatBubbleData data;

  const ChatBubble({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      alignment: data.alignment == BubbleAlignment.left
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: data.alignment == BubbleAlignment.left
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          if (data.senderName != null)
            Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                right: 12.0,
                bottom: 4.0,
              ),
              child: Text(
                data.senderName!,
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: data.backgroundColor ??
                  (data.alignment == BubbleAlignment.left
                      ? Colors.grey[300]
                      : Colors.blue[100]),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.message,
                  style: data.textStyle,
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(data.timestamp),
                      style: const TextStyle(
                        fontSize: 11.0,
                        color: Colors.black54,
                      ),
                    ),
                    if (data.status != null) ...[
                      const SizedBox(width: 4.0),
                      Text(
                        data.status!,
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}