import '../client/api_client.dart';
import '../config/constants.dart';
import '../exceptions/api_exception.dart';
import '../exceptions/message_exception.dart';
import '../models/responses/message_response.dart';
import '../models/templatez/template.dart';
import '../models/templatez/template_component.dart';
import '../utils/logger.dart';

/// Service for working with WhatsApp message templates.
class TemplateService {
  /// API client for making requests
  final ApiClient _apiClient;

  /// Phone number ID for sending messages
  final String _phoneNumberId;

  /// Logger for template service events
  final Logger _logger;

  /// Creates a new template service.
  ///
  /// [apiClient] is the API client for making requests.
  /// [phoneNumberId] is the WhatsApp Business Account phone number ID.
  /// [logger] is used for logging template service events.
  TemplateService({
    required ApiClient apiClient,
    required String phoneNumberId,
    required Logger logger,
  })  : _apiClient = apiClient,
        _phoneNumberId = phoneNumberId,
        _logger = logger {
    _logger.debug('TemplateService initialized');
  }

  /// Sends a template message using template name and components.
  ///
  /// [recipient] is the recipient's phone number.
  /// [templateName] is the name of the template to use.
  /// [language] is the language code for the template.
  /// [components] is the list of components for the template.
  /// Returns a message response with the message ID if successful.
  Future<MessageResponse> sendTemplate({
    required String recipient,
    required String templateName,
    required String language,
    List<TemplateComponent> components = const [],
  }) async {
    _logger.info('Sending template message to $recipient');
    
    final template = Template(
      name: templateName,
      language: language,
      components: components,
    );
    
    if (!template.isValid()) {
      throw MessageException.invalidContent('Invalid template data');
    }
    
    try {
      final requestData = {
        'messaging_product': 'whatsapp',
        'recipient_type': 'individual',
        'to': recipient,
        'type': 'template',
        'template': template.toJson(),
      };
      
      final endpoint = '/$_phoneNumberId/${Constants.messagePath}';
      final response = await _apiClient.post(endpoint, data: requestData);
      
      return MessageResponse.fromApiResponse(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      _logger.error('Failed to send template message', e);
      throw MessageException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to send template message', e);
      throw MessageException(
        code: 'send_template_error',
        message: 'Failed to send template message: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Gets all templates for the business account.
  ///
  /// [limit] is the maximum number of templates to return.
  /// Returns a list of templates if successful.
  Future<List<Map<String, dynamic>>> getTemplates({int limit = 20}) async {
    _logger.info('Getting templates for business account');
    
    try {
      final endpoint = '/$_phoneNumberId/${Constants.templatePath}';
      final queryParams = {
        'limit': limit.toString(),
      };
      
      final response = await _apiClient.get(
        endpoint,
        queryParameters: queryParams,
      );
      
      if (response is Map && response.containsKey('data')) {
        final data = response['data'] as List;
        return data.cast<Map<String, dynamic>>();
      }
      
      return [];
    } on ApiException catch (e) {
      _logger.error('Failed to get templates', e);
      throw MessageException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to get templates', e);
      throw MessageException(
        code: 'get_templates_error',
        message: 'Failed to get templates: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Creates a new template for the business account.
  ///
  /// [name] is the name of the template.
  /// [language] is the language code for the template.
  /// [category] is the category of the template.
  /// [components] is the list of components for the template.
  /// Returns a template response with the template ID if successful.
  Future<TemplateResponse> createTemplate({
    required String name,
    required String language,
    required String category,
    required List<Map<String, dynamic>> components,
  }) async {
    _logger.info('Creating template: $name');
    
    try {
      final requestData = {
        'name': name,
        'language': language,
        'category': category,
        'components': components,
      };
      
      final endpoint = '/$_phoneNumberId/${Constants.templatePath}';
      final response = await _apiClient.post(endpoint, data: requestData);
      
      if (response is Map && response.containsKey('id')) {
        return TemplateResponse.success(
          templateId: response['id'].toString(),
          status: response['status']?.toString(),
          data: response as Map<String, dynamic>,
        );
      } else if (response is Map && response.containsKey('error')) {
        final error = response['error'];
        return TemplateResponse.failure(
          errorMessage: (error['message'] ?? 'Unknown error').toString(),
          errorCode: error['code']?.toString(),
          data: response as Map<String, dynamic>,
        );
      }
      
      return TemplateResponse.failure(
        errorMessage: 'Failed to create template: Invalid response',
        data: response as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      _logger.error('Failed to create template', e);
      throw MessageException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to create template', e);
      throw MessageException(
        code: 'create_template_error',
        message: 'Failed to create template: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Deletes a template from the business account.
  ///
  /// [templateName] is the name of the template to delete.
  /// Returns true if successful, false otherwise.
  Future<bool> deleteTemplate(String templateName) async {
    _logger.info('Deleting template: $templateName');
    
    try {
      final endpoint = '/$_phoneNumberId/${Constants.templatePath}';
      final queryParams = {
        'name': templateName,
      };
      
      await _apiClient.delete(endpoint, queryParameters: queryParams);
      return true;
    } on ApiException catch (e) {
      _logger.error('Failed to delete template', e);
      throw MessageException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to delete template', e);
      throw MessageException(
        code: 'delete_template_error',
        message: 'Failed to delete template: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Gets details for a specific template.
  ///
  /// [templateName] is the name of the template to retrieve.
  /// Returns the template details if successful.
  Future<Map<String, dynamic>> getTemplateDetails(String templateName) async {
    _logger.info('Getting details for template: $templateName');
    
    try {
      final endpoint = '/$_phoneNumberId/${Constants.templatePath}';
      final queryParams = {
        'name': templateName,
      };
      
      final response = await _apiClient.get(
        endpoint,
        queryParameters: queryParams,
      );
      
      if (response is Map && response.containsKey('data')) {
        final data = response['data'] as List;
        if (data.isNotEmpty) {
          return data.first as Map<String, dynamic>;
        }
      }
      
      throw MessageException.templateNotFound(templateName);
    } on ApiException catch (e) {
      _logger.error('Failed to get template details', e);
      throw MessageException.fromApiException(e);
    } catch (e) {
      if (e is MessageException) rethrow;
      
      _logger.error('Failed to get template details', e);
      throw MessageException(
        code: 'get_template_details_error',
        message: 'Failed to get template details: ${e.toString()}',
        originalException: e,
      );
    }
  }
}