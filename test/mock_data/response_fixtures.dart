/// Mock response fixtures for testing.
library response_fixtures;

/// A successful message response from the API.
final Map<String, dynamic> successMessageResponse = {
  'messaging_product': 'whatsapp',
  'contacts': [
    {
      'input': '+9876543210',
      'wa_id': '9876543210',
    }
  ],
  'messages': [
    {
      'id': 'wamid.123456789',
    }
  ],
};

/// An error message response from the API.
final Map<String, dynamic> errorMessageResponse = {
  'error': {
    'message': 'Invalid recipient',
    'type': 'OAuthException',
    'code': 'invalid_parameter',
    'error_subcode': 1234,
    'fbtrace_id': 'abcdef123456789',
  },
};

/// A successful media upload response from the API.
final Map<String, dynamic> successMediaResponse = {
  'messaging_product': 'whatsapp',
  'id': '123456789',
  'url': 'https://example.com/media/123456789',
};

/// An error media upload response from the API.
final Map<String, dynamic> errorMediaResponse = {
  'error': {
    'message': 'File too large',
    'type': 'OAuthException',
    'code': 'file_too_large',
    'error_subcode': 5678,
    'fbtrace_id': 'abcdef123456789',
  },
};

/// A successful template response from the API.
final Map<String, dynamic> successTemplateResponse = {
  'id': 'template123456789',
  'status': 'APPROVED',
  'category': 'MARKETING',
};

/// A list of templates response from the API.
final Map<String, dynamic> templatesListResponse = {
  'data': [
    {
      'name': 'welcome_template',
      'id': 'template123456789',
      'status': 'APPROVED',
      'category': 'MARKETING',
    },
    {
      'name': 'order_confirmation',
      'id': 'template987654321',
      'status': 'APPROVED',
      'category': 'UTILITY',
    },
  ],
  'paging': {
    'cursors': {
      'before': 'abc123',
      'after': 'xyz789',
    },
  },
};

/// A message event webhook payload.
final Map<String, dynamic> messageWebhookPayload = {
  'object': 'whatsapp_business_account',
  'entry': [
    {
      'id': '12345',
      'changes': [
        {
          'value': {
            'messaging_product': 'whatsapp',
            'metadata': {
              'display_phone_number': '+1234567890',
              'phone_number_id': '1234567890',
            },
            'messages': [
              {
                'id': 'wamid.123456789',
                'from': '+9876543210',
                'timestamp': '1677023354',
                'type': 'text',
                'text': {
                  'body': 'Hello, World!',
                },
              },
            ],
          },
          'field': 'messages',
        },
      ],
    },
  ],
};

/// A status update webhook payload.
final Map<String, dynamic> statusWebhookPayload = {
  'object': 'whatsapp_business_account',
  'entry': [
    {
      'id': '12345',
      'changes': [
        {
          'value': {
            'messaging_product': 'whatsapp',
            'metadata': {
              'display_phone_number': '+1234567890',
              'phone_number_id': '1234567890',
            },
            'statuses': [
              {
                'id': 'wamid.123456789',
                'recipient_id': '+9876543210',
                'status': 'delivered',
                'timestamp': '1677023360',
                'conversation': {
                  'id': 'conv.123456789',
                  'origin': {
                    'type': 'business_initiated',
                  },
                },
              },
            ],
          },
          'field': 'messages',
        },
      ],
    },
  ],
};