import 'package:flutter/material.dart';

import '../services/message_service.dart';
import '../utils/validators.dart';

/// A widget for composing and sending WhatsApp messages.
class MessageComposer extends StatefulWidget {
  /// Message service for sending messages
  final MessageService messageService;

  /// Recipient's phone number
  final String recipient;

  /// Placeholder text for the input field
  final String? placeholder;

  /// Maximum number of lines for the input field
  final int maxLines;

  /// Whether to enable URL previews
  final bool previewUrl;

  /// Callback when a message is sent successfully
  final Function(String messageId)? onMessageSent;

  /// Callback when an error occurs
  final Function(String error)? onError;

  /// Creates a new message composer widget.
  ///
  /// [messageService] is used to send the message.
  /// [recipient] is the recipient's phone number.
  /// [placeholder] is optional placeholder text for the input field.
  /// [maxLines] controls the maximum number of lines (default: 5).
  /// [previewUrl] determines whether to show URL previews (default: true).
  /// [onMessageSent] is called when a message is sent successfully.
  /// [onError] is called when an error occurs.
  const MessageComposer({
    Key? key,
    required this.messageService,
    required this.recipient,
    this.placeholder,
    this.maxLines = 5,
    this.previewUrl = true,
    this.onMessageSent,
    this.onError,
  }) : super(key: key);

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _textController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Sends the current message.
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    
    if (text.isEmpty) {
      return;
    }
    
    try {
      // Validate recipient phone number
      Validators.validatePhoneNumber(widget.recipient);
      
      // Validate message text
      Validators.validateTextContent(text);
      
      setState(() {
        _isSending = true;
      });
      
      final response = await widget.messageService.sendTextMessage(
        recipient: widget.recipient,
        text: text,
        previewUrl: widget.previewUrl,
      );
      
      if (response.successful && response.messageId != null) {
        _textController.clear();
        widget.onMessageSent?.call(response.messageId!);
      } else {
        widget.onError?.call(response.errorMessage ?? 'Failed to send message');
      }
    } catch (e) {
      widget.onError?.call(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: widget.placeholder ?? 'Type a message',
                border: InputBorder.none,
                enabled: !_isSending,
              ),
              maxLines: widget.maxLines,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
            ),
          ),
          const SizedBox(width: 8.0),
          _isSending
              ? const CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                )
              : IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.green,
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }
}