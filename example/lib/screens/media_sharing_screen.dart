import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart' as wa_cloud;

import '../utils/whatsapp_client.dart';
import '../utils/chat_models.dart';

/// Screen for demonstrating media sharing capabilities.
class MediaSharingScreen extends StatefulWidget {
  /// Recipient's phone number
  final String recipient;

  /// Creates a new media sharing screen.
  ///
  /// [recipient] is the phone number to send media to.
  const MediaSharingScreen({
    Key? key,
    required this.recipient,
  }) : super(key: key);

  @override
  State<MediaSharingScreen> createState() => _MediaSharingScreenState();
}

class _MediaSharingScreenState extends State<MediaSharingScreen> {
  final _captionController = TextEditingController();
  final List<ChatBubbleData> _messages = [];
  bool _isSending = false;
  wa_cloud.MediaType _selectedMediaType = wa_cloud.MediaType.image;
  File? _selectedFile;
  String? _uploadedMediaId;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  /// Picks a file from the device.
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: _getFileType(),
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null) {
          setState(() {
            _selectedFile = File(path);
            _uploadedMediaId = null; // Reset uploaded media ID
          });
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick file: ${e.toString()}');
    }
  }

  /// Gets the file type for the file picker based on selected media type.
  FileType _getFileType() {
    switch (_selectedMediaType) {
      case wa_cloud.MediaType.image:
        return FileType.image;
      case wa_cloud.MediaType.video:
        return FileType.video;
      case wa_cloud.MediaType.audio:
        return FileType.audio;
      case wa_cloud.MediaType.document:
        return FileType.any;
      case wa_cloud.MediaType.sticker:
        return FileType.image;
    }
  }

  /// Uploads the selected file to WhatsApp.
  Future<void> _uploadMedia() async {
    if (_selectedFile == null) {
      _showErrorSnackbar('Please select a file first');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final response = await WhatsAppClientUtil.mediaService.uploadMedia(
        mediaType: _selectedMediaType,
        file: _selectedFile!,
      );

      if (response.successful && response.mediaId != null) {
        setState(() {
          _uploadedMediaId = response.mediaId;
        });
        _showSuccessSnackbar('Media uploaded successfully');
      } else {
        _showErrorSnackbar(
          response.errorMessage ?? 'Failed to upload media',
        );
      }
    } catch (e) {
      _showErrorSnackbar('Failed to upload media: ${e.toString()}');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  /// Sends the media message to the recipient.
  Future<void> _sendMediaMessage() async {
    if (_selectedFile == null && _uploadedMediaId == null) {
      _showErrorSnackbar('Please select and upload a file first');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // Prepare media information
      final caption = _captionController.text.trim();
      final messageService = WhatsAppClientUtil.messageService;
      final filename = _selectedFile?.path.split('/').last;
      
      // Add message to UI immediately (optimistic update)
      setState(() {
        _messages.insert(
          0,
          ChatBubbleData(
            message: caption.isEmpty 
                ? '[${_selectedMediaType.value.toUpperCase()}]' 
                : '${_selectedMediaType.value.toUpperCase()}: $caption',
            timestamp: DateTime.now(),
            alignment: BubbleAlignment.right,
            status: 'Sending...',
          ),
        );
      });
      
      // Create and send the appropriate media message based on type
      wa_cloud.MessageResponse response;
      
      if (_uploadedMediaId != null) {
        // If we have already uploaded the media, use the media ID
        switch (_selectedMediaType) {
          case wa_cloud.MediaType.image:
            response = await messageService.sendImageMessage(
              recipient: widget.recipient,
              source: wa_cloud.MediaSource.id,
              mediaId: _uploadedMediaId,
              caption: caption.isNotEmpty ? caption : null,
            );
            break;
          case wa_cloud.MediaType.video:
            response = await messageService.sendVideoMessage(
              recipient: widget.recipient,
              source: wa_cloud.MediaSource.id,
              mediaId: _uploadedMediaId,
              caption: caption.isNotEmpty ? caption : null,
            );
            break;
          case wa_cloud.MediaType.audio:
            response = await messageService.sendAudioMessage(
              recipient: widget.recipient,
              source: wa_cloud.MediaSource.id,
              mediaId: _uploadedMediaId,
            );
            break;
          case wa_cloud.MediaType.document:
            response = await messageService.sendDocumentMessage(
              recipient: widget.recipient,
              source: wa_cloud.MediaSource.id,
              mediaId: _uploadedMediaId,
              caption: caption.isNotEmpty ? caption : null,
              filename: filename,
            );
            break;
          case wa_cloud.MediaType.sticker:
            response = await messageService.sendStickerMessage(
              recipient: widget.recipient,
              source: wa_cloud.MediaSource.id,
              mediaId: _uploadedMediaId,
            );
            break;
        }
      } else {
        // If we need to upload on-the-fly, first upload the media
        final mediaResponse = await WhatsAppClientUtil.mediaService.uploadMedia(
          mediaType: _selectedMediaType,
          file: _selectedFile!,
        );
        
        if (!mediaResponse.successful || mediaResponse.mediaId == null) {
          throw Exception(
            mediaResponse.errorMessage ?? 'Failed to upload media',
          );
        }
        
        // Then send the message with the uploaded media ID
        final mediaId = mediaResponse.mediaId!;
        setState(() {
          _uploadedMediaId = mediaId;
        });
        
        // Create and send the message with the new media ID
        switch (_selectedMediaType) {
          case wa_cloud.MediaType.image:
            response = await messageService.sendImageMessage(
              recipient: widget.recipient,
              source: wa_cloud.MediaSource.id,
              mediaId: mediaId,
              caption: caption.isNotEmpty ? caption : null,
            );
            break;
          case wa_cloud.MediaType.video:
            response = await messageService.sendVideoMessage(
              recipient: widget.recipient,
              source: wa_cloud.MediaSource.id,
              mediaId: mediaId,
              caption: caption.isNotEmpty ? caption : null,
            );
            break;
          case wa_cloud.MediaType.audio:
            response = await messageService.sendAudioMessage(
              recipient: widget.recipient,
              source: wa_cloud.MediaSource.id,
              mediaId: mediaId,
            );
            break;
          case wa_cloud.MediaType.document:
            response = await messageService.sendDocumentMessage(
              recipient: widget.recipient,
              source: wa_cloud.MediaSource.id,
              mediaId: mediaId,
              caption: caption.isNotEmpty ? caption : null,
              filename: filename,
            );
            break;
          case wa_cloud.MediaType.sticker:
            response = await messageService.sendStickerMessage(
              recipient: widget.recipient,
              source: wa_cloud.MediaSource.id,
              mediaId: mediaId,
            );
            break;
        }
      }

      // Update the message status based on the response
      setState(() {
        if (response.successful) {
          _messages[0] = ChatBubbleData(
            message: caption.isEmpty 
                ? '[${_selectedMediaType.value.toUpperCase()}]' 
                : '${_selectedMediaType.value.toUpperCase()}: $caption',
            timestamp: DateTime.now(),
            alignment: BubbleAlignment.right,
            status: 'Sent',
            messageId: response.messageId,
          );
          _captionController.clear();
        } else {
          _messages[0] = ChatBubbleData(
            message: caption.isEmpty 
                ? '[${_selectedMediaType.value.toUpperCase()}]' 
                : '${_selectedMediaType.value.toUpperCase()}: $caption',
            timestamp: DateTime.now(),
            alignment: BubbleAlignment.right,
            status: 'Failed to send',
            backgroundColor: Colors.red.shade100,
          );
          _showErrorSnackbar(
            response.errorMessage ?? 'Failed to send media message',
          );
        }
      });
    } catch (e) {
      setState(() {
        // Update the message status if there's an error
        if (_messages.isNotEmpty) {
          _messages[0] = ChatBubbleData(
            message: _messages[0].message,
            timestamp: DateTime.now(),
            alignment: BubbleAlignment.right,
            status: 'Error',
            backgroundColor: Colors.red.shade100,
          );
        }
      });
      _showErrorSnackbar('Failed to send media message: ${e.toString()}');
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

  /// Displays a success message.
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Media Sharing'),
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
          
          // Media selector and chat section
          Expanded(
            child: Row(
              children: [
                // Media selector (left panel)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: _buildMediaSelector(),
                ),
                // Vertical divider
                Container(
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                // Chat messages (right panel)
                Expanded(
                  child: _messages.isEmpty
                      ? const Center(
                          child: Text('No messages yet. Send media to get started!'),
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
              ],
            ),
          ),
        ],
      ),
    );

  /// Builds the media selection and upload panel.
  Widget _buildMediaSelector() => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media type selection
          Text(
            'Media Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<wa_cloud.MediaType>(
            value: _selectedMediaType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: wa_cloud.MediaType.image,
                child: _buildMediaTypeItem(Icons.image, 'Image'),
              ),
              DropdownMenuItem(
                value: wa_cloud.MediaType.video,
                child: _buildMediaTypeItem(Icons.videocam, 'Video'),
              ),
              DropdownMenuItem(
                value: wa_cloud.MediaType.audio,
                child: _buildMediaTypeItem(Icons.audiotrack, 'Audio'),
              ),
              DropdownMenuItem(
                value: wa_cloud.MediaType.document,
                child: _buildMediaTypeItem(Icons.insert_drive_file, 'Document'),
              ),
              DropdownMenuItem(
                value: wa_cloud.MediaType.sticker,
                child: _buildMediaTypeItem(Icons.emoji_emotions, 'Sticker'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedMediaType = value;
                  _selectedFile = null;
                  _uploadedMediaId = null;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          
          // File selection
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Select File'),
                  onPressed: _isSending ? null : _pickFile,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_selectedFile != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected File:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _selectedFile!.path.split('/').last,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          
          // Caption input (not for audio or sticker)
          if (_selectedMediaType != wa_cloud.MediaType.audio && 
              _selectedMediaType != wa_cloud.MediaType.sticker)
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Caption (optional)',
                border: OutlineInputBorder(),
              ),
              enabled: !_isSending,
              maxLength: 1024,
              maxLines: 3,
            ),
          const SizedBox(height: 8),
          
          // Upload and send buttons
          Row(
            children: [
              if (_selectedFile != null && _uploadedMediaId == null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSending ? null : _uploadMedia,
                    child: _isSending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          )
                        : const Text('Upload First'),
                  ),
                ),
              if (_selectedFile != null && _uploadedMediaId == null)
                const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSending || _selectedFile == null ? null : _sendMediaMessage,
                  child: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : Text(_uploadedMediaId != null ? 'Send Media' : 'Upload & Send'),
                ),
              ),
            ],
          ),
          
          // Success indicator for uploaded media
          if (_uploadedMediaId != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Media uploaded (ID: ${_uploadedMediaId!.substring(0, 8)}...)',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            
          const Spacer(),
          
          // Media limitations info
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Media Limitations:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Images: ${_formatSize(wa_cloud.MediaType.image.maxSizeBytes)} max',
                  ),
                  Text(
                    '• Videos: ${_formatSize(wa_cloud.MediaType.video.maxSizeBytes)} max',
                  ),
                  Text(
                    '• Audio: ${_formatSize(wa_cloud.MediaType.audio.maxSizeBytes)} max',
                  ),
                  Text(
                    '• Documents: ${_formatSize(wa_cloud.MediaType.document.maxSizeBytes)} max',
                  ),
                  Text(
                    '• Stickers: ${_formatSize(wa_cloud.MediaType.sticker.maxSizeBytes)} max (WebP)',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  /// Builds a media type item for the dropdown.
  Widget _buildMediaTypeItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  /// Formats a file size for display.
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  /// Shows information about this example.
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Media Sharing Example'),
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
              Text('• Select different types of media files'),
              Text('• Upload media to WhatsApp Cloud API'),
              Text('• Send various types of media messages'),
              Text('• Add captions to media where supported'),
              SizedBox(height: 16),
              Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Different media types have different size limitations',
              ),
              Text(
                '• You can upload media first and then send it, or do both in one step',
              ),
              Text(
                '• Audio files don\'t support captions',
              ),
              Text(
                '• Stickers must be in WebP format with specific dimensions',
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