import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../client/api_client.dart';
import '../config/constants.dart';
import '../exceptions/api_exception.dart';
import '../exceptions/media_exception.dart';
import '../models/media/media_file.dart';
import '../models/media/media_type.dart';
import '../models/responses/message_response.dart';
import '../utils/logger.dart';

/// Service for uploading and managing media for WhatsApp Cloud API.
class MediaService {
  /// API client for making requests
  final ApiClient _apiClient;

  /// Phone number ID for media operations
  final String _phoneNumberId;

  /// Logger for media service events
  final Logger _logger;

  /// Creates a new media service.
  ///
  /// [apiClient] is the API client for making requests.
  /// [phoneNumberId] is the WhatsApp Business Account phone number ID.
  /// [logger] is used for logging media service events.
  MediaService({
    required ApiClient apiClient,
    required String phoneNumberId,
    required Logger logger,
  })  : _apiClient = apiClient,
        _phoneNumberId = phoneNumberId,
        _logger = logger {
    _logger.debug('MediaService initialized');
  }

  /// Uploads a media file to WhatsApp Cloud API.
  ///
  /// [mediaType] is the type of media.
  /// [file] is the file to upload.
  /// [filename] is an optional custom filename.
  /// Returns a media response with the media ID if successful.
  Future<MediaResponse> uploadMedia({
    required MediaType mediaType,
    required File file,
    String? filename,
  }) async {
    _logger.info('Uploading media file: ${file.path}');
    
    try {
      // Create MediaFile object from file
      final mediaFile = await MediaFile.fromFile(
        file,
        type: mediaType,
        filename: filename,
      );
      
      return _uploadMediaFile(mediaFile);
    } on MediaException catch (e) {
      _logger.error('Media validation failed', e);
      throw e;
    } catch (e) {
      _logger.error('Failed to upload media file', e);
      throw MediaException(
        code: 'media_upload_error',
        message: 'Failed to upload media file: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Uploads media bytes to WhatsApp Cloud API.
  ///
  /// [mediaType] is the type of media.
  /// [bytes] is the raw file data.
  /// [mimeType] is the MIME type of the file.
  /// [filename] is the name of the file.
  /// Returns a media response with the media ID if successful.
  Future<MediaResponse> uploadMediaBytes({
    required MediaType mediaType,
    required Uint8List bytes,
    required String mimeType,
    required String filename,
  }) async {
    _logger.info('Uploading media bytes: $filename');
    
    try {
      // Check file size
      if (bytes.length > mediaType.maxSizeBytes) {
        throw MediaException.fileSizeExceeded(
          bytes.length,
          mediaType.maxSizeBytes,
        );
      }
      
      // Check if MIME type is supported
      if (!mediaType.supportsMimeType(mimeType)) {
        throw MediaException.unsupportedMediaType(mimeType);
      }
      
      final mediaFile = MediaFile(
        type: mediaType,
        bytes: bytes,
        mimeType: mimeType,
        filename: filename,
      );
      
      return _uploadMediaFile(mediaFile);
    } on MediaException catch (e) {
      _logger.error('Media validation failed', e);
      throw e;
    } catch (e) {
      _logger.error('Failed to upload media bytes', e);
      throw MediaException(
        code: 'media_upload_error',
        message: 'Failed to upload media bytes: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Uploads media from a URL to WhatsApp Cloud API.
  ///
  /// Note: The URL must be publicly accessible.
  ///
  /// [mediaType] is the type of media.
  /// [url] is the URL of the media.
  /// Returns a media response with the media ID if successful.
  Future<MediaResponse> uploadMediaFromUrl({
    required MediaType mediaType,
    required String url,
  }) async {
    _logger.info('Uploading media from URL: $url');
    
    try {
      final requestData = {
        'messaging_product': 'whatsapp',
        'type': mediaType.value,
        'url': url,
      };
      
      final endpoint = '/$_phoneNumberId/${Constants.mediaPath}';
      final response = await _apiClient.post(endpoint, data: requestData);
      
      if (response is Map && response.containsKey('id')) {
        return MediaResponse.success(
          mediaId: response['id'].toString(),
          data: response as Map<String, dynamic>,
        );
      } else if (response is Map && response.containsKey('error')) {
        final error = response['error'];
        return MediaResponse.failure(
          errorMessage: (error['message'] ?? 'Unknown error').toString(),
          errorCode: error['code']?.toString(),
          data: response as Map<String, dynamic>,
        );
      }
      
      return MediaResponse.failure(
        errorMessage: 'Failed to upload media from URL: Invalid response',
        data: response as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      _logger.error('Failed to upload media from URL', e);
      throw MediaException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to upload media from URL', e);
      throw MediaException(
        code: 'media_upload_url_error',
        message: 'Failed to upload media from URL: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Gets metadata for a media file.
  ///
  /// [mediaId] is the ID of the media to retrieve.
  /// Returns a map containing media metadata if successful.
  Future<Map<String, dynamic>> getMediaDetails(String mediaId) async {
    _logger.info('Getting details for media: $mediaId');
    
    try {
      final endpoint = '$mediaId';
      final response = await _apiClient.get(endpoint);
      
      return response as Map<String, dynamic>;
    } on ApiException catch (e) {
      _logger.error('Failed to get media details', e);
      throw MediaException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to get media details', e);
      throw MediaException(
        code: 'get_media_details_error',
        message: 'Failed to get media details: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Downloads a media file.
  ///
  /// [mediaId] is the ID of the media to download.
  /// Returns the raw file bytes if successful.
  Future<Uint8List> downloadMedia(String mediaId) async {
    _logger.info('Downloading media: $mediaId');
    
    try {
      // First, get the media URL
      final details = await getMediaDetails(mediaId);
      
      if (!details.containsKey('url')) {
        throw MediaException(
          code: 'missing_media_url',
          message: 'Media URL not found in response',
        );
      }
      
      final mediaUrl = details['url'] as String;
      
      // Create a new Dio instance for downloading
      final dio = Dio();
      
      // Add authentication headers from the API client
      dio.options.headers.addAll(_apiClient.authManager.getAuthHeaders());
      
      // Download the file
      final response = await dio.get<List<int>>(
        mediaUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      
      if (response.data == null) {
        throw MediaException(
          code: 'download_media_error',
          message: 'Downloaded media is empty',
        );
      }
      
      return Uint8List.fromList(response.data!);
    } on ApiException catch (e) {
      _logger.error('Failed to download media', e);
      throw MediaException.fromApiException(e);
    } catch (e) {
      if (e is MediaException) rethrow;
      
      _logger.error('Failed to download media', e);
      throw MediaException(
        code: 'download_media_error',
        message: 'Failed to download media: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Deletes a media file.
  ///
  /// [mediaId] is the ID of the media to delete.
  /// Returns true if successful, false otherwise.
  Future<bool> deleteMedia(String mediaId) async {
    _logger.info('Deleting media: $mediaId');
    
    try {
      final endpoint = '$mediaId';
      await _apiClient.delete(endpoint);
      return true;
    } on ApiException catch (e) {
      _logger.error('Failed to delete media', e);
      throw MediaException.fromApiException(e);
    } catch (e) {
      _logger.error('Failed to delete media', e);
      throw MediaException(
        code: 'delete_media_error',
        message: 'Failed to delete media: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Internal method to upload a media file.
  Future<MediaResponse> _uploadMediaFile(MediaFile mediaFile) async {
    try {
      final endpoint = '/$_phoneNumberId/${Constants.mediaPath}';
      
      // Create form data
      final formData = FormData.fromMap({
        'messaging_product': 'whatsapp',
        'type': mediaFile.type.value,
        'file': MultipartFile.fromBytes(
          mediaFile.bytes,
          filename: mediaFile.filename,
          contentType: DioMediaType.parse(mediaFile.mimeType),
        ),
      });
      
      // Use the API client's post method for multipart requests
      final response = await _apiClient.post(
        endpoint,
        data: formData,
      );
      
      if (response.data is Map && (response.data as Map).containsKey('id')) {
        return MediaResponse.success(
          mediaId: response.data['id'].toString(),
          data: response.data as Map<String, dynamic>,
        );
      } else if (response.data is Map && (response.data as Map).containsKey('error')) {
        final error = response.data['error'];
        return MediaResponse.failure(
          errorMessage: (error['message'] ?? 'Unknown error').toString(),
          errorCode: error['code']?.toString(),
          data: response.data as Map<String, dynamic>,
        );
      }
      
      return MediaResponse.failure(
        errorMessage: 'Failed to upload media: Invalid response',
        data: response.data is Map ? response.data as Map<String, dynamic> : null,
      );
    } on DioException catch (e) {
      _logger.error('Failed to upload media file', e);
      throw MediaException.uploadFailure(e);
    } catch (e) {
      _logger.error('Failed to upload media file', e);
      throw MediaException.uploadFailure(e);
    }
  }
}