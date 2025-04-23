import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'simple_messaging_screen.dart';
import 'template_messaging_screen.dart';
import 'media_sharing_screen.dart';
import 'webhook_handling_screen.dart';
import '../utils/whatsapp_client.dart';

/// Home screen for the example app with navigation to feature demonstrations.
class HomeScreen extends StatefulWidget {
  /// Creates a new home screen instance.
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _recipientController = TextEditingController();
  final _phoneNumberIdController = TextEditingController();
  final _accessTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Try to load values from environment variables
    _phoneNumberIdController.text = dotenv.env['PHONE_NUMBER_ID'] ?? '';
    _accessTokenController.text = dotenv.env['ACCESS_TOKEN'] ?? '';
    _recipientController.text = dotenv.env['DEFAULT_RECIPIENT'] ?? '';
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _phoneNumberIdController.dispose();
    _accessTokenController.dispose();
    super.dispose();
  }

  /// Validates the form inputs and initializes the WhatsApp client.
  void _initializeAndNavigate(Widget screen) {
    final phoneNumberId = _phoneNumberIdController.text.trim();
    final accessToken = _accessTokenController.text.trim();
    final recipient = _recipientController.text.trim();
    
    if (phoneNumberId.isEmpty || accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone Number ID and Access Token are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (recipient.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipient phone number is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Initialize the shared WhatsApp client
    WhatsAppClientUtil.initialize(
      phoneNumberId: phoneNumberId,
      accessToken: accessToken,
    );
    
    // Navigate to the selected screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Cloud API Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Configuration section
            const Text(
              'Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneNumberIdController,
              decoration: const InputDecoration(
                labelText: 'Phone Number ID',
                border: OutlineInputBorder(),
                hintText: 'Enter your WhatsApp Business Phone Number ID',
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _accessTokenController,
              decoration: const InputDecoration(
                labelText: 'Access Token',
                border: OutlineInputBorder(),
                hintText: 'Enter your API Access Token',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient Phone Number',
                border: OutlineInputBorder(),
                hintText: 'Enter recipient phone number with country code',
              ),
            ),
            const SizedBox(height: 24),
            
            // Features section
            const Text(
              'Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    icon: Icons.message,
                    title: 'Simple Messaging',
                    description: 'Send and receive text messages',
                    onTap: () => _initializeAndNavigate(
                      SimpleMessagingScreen(
                        recipient: _recipientController.text.trim(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    icon: Icons.article,
                    title: 'Template Messaging',
                    description: 'Send template-based messages',
                    onTap: () => _initializeAndNavigate(
                      TemplateMessagingScreen(
                        recipient: _recipientController.text.trim(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    icon: Icons.photo_library,
                    title: 'Media Sharing',
                    description: 'Share images, videos, and documents',
                    onTap: () => _initializeAndNavigate(
                      MediaSharingScreen(
                        recipient: _recipientController.text.trim(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    icon: Icons.webhook,
                    title: 'Webhook Handling',
                    description: 'Process incoming notifications',
                    onTap: () => _initializeAndNavigate(
                      const WebhookHandlingScreen(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  /// Builds a feature card widget for the grid.
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) => Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
}