import 'package:flutter/material.dart';

import '../services/template_service.dart';
import '../models/templatez/template_component.dart';

/// A widget for selecting and sending WhatsApp message templates.
class TemplateSelector extends StatefulWidget {
  /// Template service for retrieving and sending templates
  final TemplateService templateService;

  /// Recipient's phone number
  final String recipient;

  /// Language code for templates
  final String languageCode;

  /// Callback when a template is sent successfully
  final Function(String messageId)? onTemplateSent;

  /// Callback when an error occurs
  final Function(String error)? onError;

  /// Creates a new template selector widget.
  ///
  /// [templateService] is used to retrieve and send templates.
  /// [recipient] is the recipient's phone number.
  /// [languageCode] is the language code for templates (default: 'en_US').
  /// [onTemplateSent] is called when a template is sent successfully.
  /// [onError] is called when an error occurs.
  const TemplateSelector({
    Key? key,
    required this.templateService,
    required this.recipient,
    this.languageCode = 'en_US',
    this.onTemplateSent,
    this.onError,
  }) : super(key: key);

  @override
  State<TemplateSelector> createState() => _TemplateSelectorState();
}

class _TemplateSelectorState extends State<TemplateSelector> {
  bool _isLoading = false;
  bool _isSending = false;
  List<Map<String, dynamic>> _templates = [];
  Map<String, dynamic>? _selectedTemplate;
  Map<String, TextEditingController> _parameterControllers = {};

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _parameterControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  /// Loads available templates from the API.
  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final templates = await widget.templateService.getTemplates();
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      widget.onError?.call('Failed to load templates: ${e.toString()}');
    }
  }

  /// Handles template selection.
  void _selectTemplate(Map<String, dynamic> template) {
    setState(() {
      _selectedTemplate = template;
      _parameterControllers = {};

      // Create controllers for template parameters
      final components = template['components'] as List?;
      if (components != null) {
        for (final component in components) {
          final params = component['example']?['body_text']?['parameters'] as List?;
          if (params != null) {
            for (int paramIndex = 0; paramIndex < params.length; paramIndex++) {
              _parameterControllers['param_$paramIndex'] =
                  TextEditingController();
            }
          }
        }
      }
    });
  }

  /// Sends the selected template with parameters.
  Future<void> _sendTemplate() async {
    if (_selectedTemplate == null) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // Build template parameters
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

      final response = await widget.templateService.sendTemplate(
        recipient: widget.recipient,
        templateName: _selectedTemplate!['name'] as String,
        language: widget.languageCode,
        components: components,
      );

      if (response.successful && response.messageId != null) {
        widget.onTemplateSent?.call(response.messageId!);
        _clearSelection();
      } else {
        widget.onError?.call(
            response.errorMessage ?? 'Failed to send template message');
      }
    } catch (e) {
      widget.onError?.call('Error sending template: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  /// Clears the current template selection.
  void _clearSelection() {
    setState(() {
      _selectedTemplate = null;
      _parameterControllers = {};
    });
  }

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_templates.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('No templates available'),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: _loadTemplates,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          )
        else if (_selectedTemplate == null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select a message template',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final template = _templates[index];
                  return ListTile(
                    title: Text(template['name'] as String),
                    subtitle: Text((template['status'] ?? 'Unknown status').toString()),
                    onTap: () => _selectTemplate(template),
                  );
                },
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Template: ${_selectedTemplate!['name']}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _clearSelection,
                    ),
                  ],
                ),
              ),
              if (_parameterControllers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parameters',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8.0),
                      ..._parameterControllers.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: 'Parameter ${entry.key.split('_').last}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendTemplate,
                  child: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text('Send Template'),
                ),
              ),
            ],
          ),
      ],
    );
}