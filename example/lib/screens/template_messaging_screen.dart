import 'package:flutter/material.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart' as whatsapp_cloud;
import 'package:whatsapp_cloud_flutter_example/utils/chat_models.dart';
import 'package:whatsapp_cloud_flutter_example/utils/template_component.dart';

import '../utils/whatsapp_client.dart';

/// Screen for demonstrating template-based messaging.
class TemplateMessagingScreen extends StatefulWidget {
  /// Recipient's phone number
  final String recipient;

  /// Creates a new template messaging screen.
  const TemplateMessagingScreen({
    Key? key,
    required this.recipient,
  }) : super(key: key);

  @override
  State<TemplateMessagingScreen> createState() => _TemplateMessagingScreenState();
}

class _TemplateMessagingScreenState extends State<TemplateMessagingScreen> {
  List<Map<String, dynamic>> _templates = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  Map<String, dynamic>? _selectedTemplate;
  final Map<String, TextEditingController> _parameterControllers = {};
  final List<ChatBubbleData> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _clearParameterControllers();
    super.dispose();
  }

  /// Loads available templates from the API.
  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final templates = await WhatsAppClientUtil.templateService.getTemplates();
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load templates: ${e.toString()}';
      });
      _showErrorSnackbar(_errorMessage!);
    }
  }

  /// Clears parameter controllers and disposes them.
  void _clearParameterControllers() {
    for (final controller in _parameterControllers.values) {
      controller.dispose();
    }
    _parameterControllers.clear();
  }

  /// Selects a template for use and extracts parameters.
  void _selectTemplate(Map<String, dynamic> template) {
    // Clear existing controllers before creating new ones
    _clearParameterControllers();

    // Find parameters in the template
    final List<String> parameterPlaceholders = _extractParameterPlaceholders(template);

    setState(() {
      _selectedTemplate = template;
      
      // Create a controller for each parameter
      for (int i = 0; i < parameterPlaceholders.length; i++) {
        _parameterControllers['param_$i'] = TextEditingController();
      }
    });
  }

  /// Extracts placeholder parameters from a template.
  List<String> _extractParameterPlaceholders(Map<String, dynamic> template) {
    final List<String> parameters = [];
    
    // Find body component to extract parameters
    if (template.containsKey('components')) {
      final components = template['components'];
      if (components is List) {
        for (final component in components) {
          if (component is Map && component['type'] == 'BODY' && component.containsKey('text')) {
            final text = component['text'];
            if (text is String) {
              // Extract all {{parameters}} using regex
              final matches = RegExp(r'\{\{([^}]*)\}\}').allMatches(text);
              for (final match in matches) {
                parameters.add(match.group(0) ?? '{{parameter}}');
              }
            }
          }
        }
      }
    }
    
    return parameters;
  }

  /// Gets the template body text.
  String _getTemplateBodyText(Map<String, dynamic> template) {
    if (template.containsKey('components')) {
      final components = template['components'];
      if (components is List) {
        for (final component in components) {
          if (component is Map && 
              component['type'] == 'BODY' && 
              component.containsKey('text')) {
            final text = component['text'];
            if (text is String) {
              return text;
            }
          }
        }
      }
    }
    
    return template['name']?.toString() ?? 'Template';
  }

  /// Sends the selected template message.
  Future<void> _sendTemplate() async {
    if (_selectedTemplate == null) {
      _showErrorSnackbar('No template selected');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // Build template parameters if any
      final List<TemplateComponent> components = [];
      
      if (_parameterControllers.isNotEmpty) {
        final List<TemplateParameter> parameters = [];
        
        _parameterControllers.forEach((key, controller) {
          if (controller.text.isNotEmpty) {
            parameters.add(TextParameter(text: controller.text));
          }
        });

        if (parameters.isNotEmpty) {
          components.add(
            TemplateComponent(
              type: ComponentType.body,
              parameters: parameters,
            ),
          );
        }
      }

      // Prepare template data for UI
      final templateName = _selectedTemplate!['name']?.toString() ?? '';
      String templatePreview = _getTemplateBodyText(_selectedTemplate!);
      
      // Add parameter values to the preview
      int paramIndex = 0;
      for (final controller in _parameterControllers.values) {
        if (controller.text.isNotEmpty) {
          templatePreview = templatePreview.replaceFirst(
            RegExp(r'\{\{[^}]*\}\}'), 
            controller.text,
          );
        } else {
          // Replace empty parameters with placeholder
          templatePreview = templatePreview.replaceFirst(
            RegExp(r'\{\{[^}]*\}\}'), 
            '[PARAM]',
          );
        }
        paramIndex++;
      }

      // Add message to UI immediately (optimistic update)
      setState(() {
        _messages.insert(
          0,
          ChatBubbleData(
            message: 'Template: $templateName\n$templatePreview',
            timestamp: DateTime.now(),
            alignment: BubbleAlignment.right,
            status: 'Sending...',
          ),
        );
      });

      // Send the template message
      final response = await WhatsAppClientUtil.templateService.sendTemplate(
        recipient: widget.recipient,
        templateName: templateName,
        language: 'en_US', // Default to English
        // components: components,
      );

      setState(() {
        if (response.successful && response.messageId != null) {
          // Update status if successful
          _messages[0] = ChatBubbleData(
            message: _messages[0].message,
            timestamp: DateTime.now(),
            alignment: BubbleAlignment.right,
            status: 'Sent',
            messageId: response.messageId,
          );
          
          // Clear the selected template and parameters
          _selectedTemplate = null;
          _clearParameterControllers();
        } else {
          // Update status if failed
          _messages[0] = ChatBubbleData(
            message: _messages[0].message,
            timestamp: DateTime.now(),
            alignment: BubbleAlignment.right,
            status: 'Failed to send',
            backgroundColor: Colors.red.shade100,
          );
          _showErrorSnackbar(response.errorMessage ?? 'Failed to send template message');
        }
      });
    } catch (e) {
      setState(() {
        // Update message status on error
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
      _showErrorSnackbar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  /// Shows an error message.
  void _showErrorSnackbar(String errorMessage) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Template Messaging'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadTemplates,
            tooltip: 'Reload templates',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
            tooltip: 'Information',
          ),
        ],
      ),
      body: Column(
        children: [
          // Recipient info
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.green.shade50,
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
          
          // Main content area
          Expanded(
            child: Row(
              children: [
                // Template selector (left panel)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: _buildTemplateList(),
                ),
                // Vertical divider
                Container(
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                // Chat messages (right panel)
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, 
                                size: 48, 
                                color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              const Text(
                                'No messages yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Select a template to send',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
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
          
          // Template parameters (if template is selected)
          if (_selectedTemplate != null) _buildParameterInputs(),
        ],
      ),
    );

  /// Builds the template selection list.
  Widget _buildTemplateList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading templates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTemplates,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description_outlined, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            Text(
              'No templates found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Create templates in your WhatsApp Business Platform account',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(Icons.format_list_bulleted, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Available Templates (${_templates.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              final template = _templates[index];
              final name = template['name']?.toString() ?? 'Unnamed template';
              final status = template['status']?.toString() ?? 'Unknown status';
              final category = template['category']?.toString() ?? 'No category';
              
              final isSelected = _selectedTemplate != null &&
                  _selectedTemplate!['name'] == template['name'];
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: isSelected ? 2 : 0,
                color: isSelected ? Colors.green.shade50 : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? Colors.green : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () => _selectTemplate(template),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: status == 'APPROVED'
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: status == 'APPROVED'
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the parameter input section.
  Widget _buildParameterInputs() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _parameterControllers.isEmpty 
                      ? 'Send Template' 
                      : 'Template Parameters',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedTemplate = null),
                tooltip: 'Cancel',
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Template preview
          if (_selectedTemplate != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preview:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTemplateBodyText(_selectedTemplate!),
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Parameter fields
          ..._parameterControllers.entries.map(
            (entry) {
              final paramIndex = int.parse(entry.key.split('_').last) + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: 'Parameter $paramIndex',
                    hintText: 'Enter value for parameter $paramIndex',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // Send button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _sendTemplate,
              icon: _isSending
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(_isSending ? 'Sending...' : 'Send Template'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
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
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Template Messaging'),
          ],
        ),
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
              Text('• Retrieve approved message templates'),
              Text('• Select templates for sending'),
              Text('• Fill in template parameters'),
              Text('• Send template messages to recipients'),
              SizedBox(height: 16),
              Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Templates must be pre-approved in the WhatsApp Business Platform.',
              ),
              Text(
                '• You can only send templates to recipients who have previously messaged your business or opted-in.',
              ),
              Text(
                '• Templates are the only way to initiate conversations with users in WhatsApp.',
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
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(message.message),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(message.timestamp),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Status: ${message.status ?? "Unknown"}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              if (message.messageId != null) ...[
                const SizedBox(height: 16),
                const Text('Message ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    message.messageId!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
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
  
  /// Formats a DateTime for display
  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    
    return '$day/$month/$year $hour:$minute:$second';
  }
}