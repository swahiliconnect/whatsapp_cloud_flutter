import 'package:flutter/material.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart' as whatsapp;
import 'package:whatsapp_cloud_flutter_example/utils/chat_models.dart';

import '../utils/whatsapp_client.dart';

/// Screen for demonstrating simple text messaging.
class SimpleMessagingScreen extends StatefulWidget {
  /// Recipient's phone number
  final String recipient;

  /// Creates a new simple messaging screen.
  ///
  /// [recipient] is the phone number to send messages to.
  const SimpleMessagingScreen({
    Key? key,
    required this.recipient,
  }) : super(key: key);

  @override
  State<SimpleMessagingScreen> createState() => _SimpleMessagingScreenState();
}

class _SimpleMessagingScreenState extends State<SimpleMessagingScreen> {
  final _textController = TextEditingController();
  final List<ChatBubbleData> _messages = [];
  bool _isSending = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Sends a text message to the recipient.
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
      // Add message to UI immediately (optimistic update)
      _messages.insert(
        0,
        ChatBubbleData(
          message: text,
          timestamp: DateTime.now(),
          alignment: BubbleAlignment.right,
          status: 'Sending...',
        ),
      );
    });

    try {
      final response = await WhatsAppClientUtil.messageService.sendTextMessage(
        recipient: widget.recipient,
        text: text,
        previewUrl: true,
      );

      setState(() {
        // Update the status of the sent message
        if (response.successful) {
          _messages[0] = ChatBubbleData(
            message: text,
            timestamp: DateTime.now(),
            alignment: BubbleAlignment.right,
            status: 'Sent',
            messageId: response.messageId,
          );
          _textController.clear();
        } else {
          _messages[0] = ChatBubbleData(
            message: text,
            timestamp: DateTime.now(),
            alignment: BubbleAlignment.right,
            status: 'Failed to send',
            backgroundColor: Colors.red.shade100,
          );
          _showErrorSnackbar(response.errorMessage ?? 'Failed to send message');
        }
      });
    } catch (e) {
      setState(() {
        // Update the status if there's an error
        _messages[0] = ChatBubbleData(
          message: text,
          timestamp: DateTime.now(),
          alignment: BubbleAlignment.right,
          status: 'Error',
          backgroundColor: Colors.red.shade100,
        );
      });
      _showErrorSnackbar(e.toString());
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  /// Displays an error message.
  void _showErrorSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Messaging'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Recipient info
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.green),
                const SizedBox(width: 8.0),
                Text(
                  'Recipient: ${widget.recipient}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('No messages yet. Send your first message!'),
                  )
                : ChatConversation(
                    messages: _messages,
                    onMessageTap: (message) {
                      // Show message details when tapped
                      if (message.messageId != null) {
                        _showMessageDetailsDialog(message);
                      }
                    },
                  ),
          ),
          
          // Message input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isSending,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                _isSending
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.send),
                        color: Colors.green,
                        onPressed: _sendMessage,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shows information about this example.
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simple Messaging Example'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This example demonstrates how to:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Send text messages using WhatsApp Cloud API'),
              Text('• Display messages in a chat-like interface'),
              Text('• Show delivery status information'),
              Text('• Handle error scenarios gracefully'),
              SizedBox(height: 16),
              Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• The recipient must have previously messaged your WhatsApp Business account or opted-in to receive messages.',
              ),
              Text(
                '• The WhatsApp Cloud API free tier has limitations on the number of messages you can send.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Shows details for a specific message.
  void _showMessageDetailsDialog(ChatBubbleData message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Content: ${message.message}'),
            const SizedBox(height: 8),
            Text('Status: ${message.status ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Timestamp: ${message.timestamp.toString()}'),
            const SizedBox(height: 8),
            if (message.messageId != null)
              Text('Message ID: ${message.messageId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}