import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart' as whatsapp_cloud;

import '../utils/whatsapp_client.dart';

/// Screen for demonstrating webhook handling capabilities.
class WebhookHandlingScreen extends StatefulWidget {
  /// Creates a new webhook handling screen.
  const WebhookHandlingScreen({Key? key}) : super(key: key);

  @override
  State<WebhookHandlingScreen> createState() => _WebhookHandlingScreenState();
}

class _WebhookHandlingScreenState extends State<WebhookHandlingScreen> {
  final _webhookDataController = TextEditingController();
  final _verifyTokenController = TextEditingController();
  final _challengeController = TextEditingController();
  
  final List<Map<String, dynamic>> _receivedEvents = [];
  bool _isSubscribed = false;
  String? _verificationResult;

  @override
  void initState() {
    super.initState();
    _setupWebhookHandlers();
  }

  @override
  void dispose() {
    _webhookDataController.dispose();
    _verifyTokenController.dispose();
    _challengeController.dispose();
    
    // Unregister handlers
    if (_isSubscribed) {
      _unregisterWebhookHandlers();
    }
    
    super.dispose();
  }

  /// Sets up webhook handlers.
  void _setupWebhookHandlers() {
    // Register a message handler
    WhatsAppClientUtil.webhookService.registerMessageHandler((event) {
      setState(() {
        _receivedEvents.insert(0, {
          'type': 'Message',
          'from': event.from,
          'timestamp': event.timestamp,
          'messageType': event.messageType,
          'text': event.text,
          'id': event.messageId,
          'rawPayload': event.rawPayload,
        });
      });
    });

    // Register a status handler
    WhatsAppClientUtil.webhookService.registerStatusHandler((event) {
      setState(() {
        _receivedEvents.insert(0, {
          'type': 'Status',
          'recipient': event.recipient,
          'status': event.status,
          'timestamp': event.timestamp,
          'id': event.messageId,
          'rawPayload': event.rawPayload,
        });
      });
    });

    // Register a raw webhook handler
    WhatsAppClientUtil.webhookService.registerRawHandler((payload) {
      // This handler will get all raw webhook data, but we don't need to
      // add it to the UI since the specific handlers above will add the
      // processed data
    });

    setState(() {
      _isSubscribed = true;
    });
  }

  /// Unregisters webhook handlers.
  void _unregisterWebhookHandlers() {
    // Note: We would need references to the handler functions to unregister them.
    // For this example, we're not implementing the unregistration.
    setState(() {
      _isSubscribed = false;
    });
  }

  /// Processes a webhook payload.
  void _processWebhook() {
    final data = _webhookDataController.text.trim();
    if (data.isEmpty) {
      _showErrorSnackbar('Please enter webhook data');
      return;
    }

    try {
      final Map<String, dynamic> payload = json.decode(data) as Map<String, dynamic>;
      final success = WhatsAppClientUtil.webhookService.processWebhook(payload);
      
      if (success) {
        _showSuccessSnackbar('Webhook processed successfully');
      } else {
        _showErrorSnackbar('Failed to process webhook (unsupported type)');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to parse webhook data: ${e.toString()}');
    }
  }

  /// Verifies a webhook challenge.
  void _verifyWebhook() {
    final verifyToken = _verifyTokenController.text.trim();
    
    if (verifyToken.isEmpty) {
      _showErrorSnackbar('Please enter a verification token');
      return;
    }
    
    final queryParams = {
      'hub.mode': 'subscribe',
      'hub.verify_token': verifyToken,
      'hub.challenge': _challengeController.text.trim(),
    };
    
    final challenge = WhatsAppClientUtil.webhookService.validateWebhook(
      queryParams,
      verifyToken,
    );
    
    setState(() {
      if (challenge != null) {
        _verificationResult = 'Verification Successful. Challenge: $challenge';
      } else {
        _verificationResult = 'Verification Failed';
      }
    });
  }

  /// Clears all received events.
  void _clearEvents() {
    setState(_receivedEvents.clear);
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
        title: const Text('Webhook Handling'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Webhook handler status
          Container(
            padding: const EdgeInsets.all(8.0),
            color: _isSubscribed ? Colors.green.shade100 : Colors.red.shade100,
            child: Row(
              children: [
                Icon(
                  _isSubscribed ? Icons.check_circle : Icons.error,
                  color: _isSubscribed ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _isSubscribed
                        ? 'Webhook handlers registered and ready'
                        : 'Webhook handlers not registered',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: _isSubscribed
                      ? _unregisterWebhookHandlers
                      : _setupWebhookHandlers,
                  child: Text(_isSubscribed ? 'Unregister' : 'Register'),
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Control panel (left side)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: _buildControlPanel(),
                ),
                // Vertical divider
                Container(
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                // Events list (right side)
                Expanded(
                  child: _buildEventsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  /// Builds the webhook control panel.
  Widget _buildControlPanel() => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Manual webhook processing
          Text(
            'Process Webhook Data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _webhookDataController,
            decoration: const InputDecoration(
              labelText: 'Webhook JSON Data',
              border: OutlineInputBorder(),
              hintText: '{"object": "whatsapp_business_account", ...}',
            ),
            maxLines: 8,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _processWebhook,
                  child: const Text('Process Webhook'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.content_paste),
                tooltip: 'Paste from clipboard',
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data != null && data.text != null) {
                    _webhookDataController.text = data.text!;
                  }
                },
              ),
            ],
          ),
          const Divider(height: 32),
          
          // Webhook verification
          Text(
            'Webhook Verification',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _verifyTokenController,
            decoration: const InputDecoration(
              labelText: 'Verification Token',
              border: OutlineInputBorder(),
              hintText: 'Your webhook verify token',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _challengeController,
            decoration: const InputDecoration(
              labelText: 'Challenge String',
              border: OutlineInputBorder(),
              hintText: 'hub.challenge value',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _verifyWebhook,
                  child: const Text('Verify Webhook'),
                ),
              ),
            ],
          ),
          if (_verificationResult != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _verificationResult!,
                style: TextStyle(
                  color: _verificationResult!.contains('Successful')
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          const Spacer(),
          
          // Sample webhook data
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sample Webhook JSON:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // Basic message notification
                    json.encode({
                      'object': 'whatsapp_business_account',
                      'entry': [{
                        'id': '12345',
                        'changes': [{
                          'value': {
                            'messaging_product': 'whatsapp',
                            'metadata': {
                              'display_phone_number': '+1234567890',
                              'phone_number_id': '12345'
                            },
                            'messages': [{
                              'id': 'wamid.123456',
                              'from': '+9876543210',
                              'timestamp': '${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
                              'type': 'text',
                              'text': {
                                'body': 'Hello World!'
                              }
                            }]
                          },
                          'field': 'messages'
                        }]
                      }]
                    }),
                    style: const TextStyle(fontSize: 10),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    child: const Text('Copy Sample to Input'),
                    onPressed: () {
                      _webhookDataController.text = json.encode({
                        'object': 'whatsapp_business_account',
                        'entry': [{
                          'id': '12345',
                          'changes': [{
                            'value': {
                              'messaging_product': 'whatsapp',
                              'metadata': {
                                'display_phone_number': '+1234567890',
                                'phone_number_id': '12345'
                              },
                              'messages': [{
                                'id': 'wamid.123456',
                                'from': '+9876543210',
                                'timestamp': '${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
                                'type': 'text',
                                'text': {
                                  'body': 'Hello World!'
                                }
                              }]
                            },
                            'field': 'messages'
                          }]
                        }]
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  /// Builds the events list panel.
  Widget _buildEventsList() => Column(
      children: [
        // Header with clear button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                'Received Events (${_receivedEvents.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (_receivedEvents.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'),
                  onPressed: _clearEvents,
                ),
            ],
          ),
        ),
        
        // Events list
        Expanded(
          child: _receivedEvents.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No events received yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Process a webhook to see events here',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _receivedEvents.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final event = _receivedEvents[index];
                    final isMessage = event['type'] == 'Message';
                    
                    return ListTile(
                      leading: Icon(
                        isMessage ? Icons.message : Icons.notifications,
                        color: isMessage ? Colors.blue : Colors.orange,
                      ),
                      title: Text(isMessage
                          ? 'Message from: ${event['from']}'
                          : 'Status for: ${event['recipient']}'),
                      subtitle: Text(isMessage
                          ? 'Type: ${event['messageType']}${event['text'] != null ? ' - ${event['text']}' : ''}'
                          : 'Status: ${event['status']}'),
                      trailing: Text(
                        _formatTimestamp(event['timestamp'] as DateTime),
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () => _showEventDetailsDialog(event),
                    );
                  },
                ),
        ),
      ],
    );

  /// Formats a timestamp for display.
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  /// Shows information about this example.
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Webhook Handling Example'),
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
              Text('• Process incoming webhook notifications'),
              Text('• Handle different types of events (messages, statuses)'),
              Text('• Verify webhook subscriptions'),
              Text('• Manually test webhook processing'),
              SizedBox(height: 16),
              Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• In a real application, webhooks would be received by your server',
              ),
              Text(
                '• This example simulates webhook processing using the API',
              ),
              Text(
                '• Use the sample data or paste real webhook JSON to test',
              ),
              Text(
                '• You can verify your webhook subscription validation logic',
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

  /// Shows details for a specific event.
  void _showEventDetailsDialog(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${event['type']} Event Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ID: ${event['id']}'),
            const SizedBox(height: 8),
            Text('Type: ${event['type']}'),
            const SizedBox(height: 8),
            if (event['type'] == 'Message') ...[
              Text('From: ${event['from']}'),
              const SizedBox(height: 8),
              Text('Message Type: ${event['messageType']}'),
              if (event['text'] != null) ...[
                const SizedBox(height: 8),
                Text('Text: ${event['text']}'),
              ],
            ] else ...[
              Text('Recipient: ${event['recipient']}'),
              const SizedBox(height: 8),
              Text('Status: ${event['status']}'),
            ],
            const SizedBox(height: 8),
            Text('Timestamp: ${event['timestamp']}'),
            const SizedBox(height: 16),
            const Text(
              'Raw Payload:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              height: 200,
              child: SingleChildScrollView(
                child: Text(
                  const JsonEncoder.withIndent('  ')
                      .convert(event['rawPayload']),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: const JsonEncoder.withIndent('  ')
                    .convert(event['rawPayload']),
              ));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Raw payload copied to clipboard'),
                ),
              );
            },
            child: const Text('Copy Raw'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}