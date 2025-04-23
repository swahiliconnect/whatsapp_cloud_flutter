import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../../../src/exceptions/media_exception.dart';
import 'media_type.dart';

/// Represents a media file for WhatsApp Cloud API.
///
/// This class manages the data and metadata for media files
/// that will be sent through the WhatsApp Cloud API.
@immutable
class MediaFile {
  /// The type of media (image, video, audio, document, sticker)
  final MediaType type;

  /// The raw bytes of the media file
  final Uint8List bytes;

  /// MIME type of the media file
  final String mimeType;

  /// Filename with extension
  final String filename;

  /// Creates a new media file.
  ///
  /// [type] is the type of media.
  /// [bytes] is the raw file data.
  /// [mimeType] is the MIME type of the file.
  /// [filename] is the name of the file with extension.
  const MediaFile({
    required this.type,
    required this.bytes,
    required this.mimeType,
    required this.filename,
  });

  /// Creates a media file from a file on disk.
  ///
  /// [file] is the file to read.
  /// [type] is the type of media (if null, will be inferred from file extension).
  /// [mimeType] is the MIME type (if null, will be inferred from file extension).
  /// [filename] is the name to use (if null, will use the file's basename).
  static Future<MediaFile> fromFile(
    File file, {
    MediaType? type,
    String? mimeType,
    String? filename,
  }) async {
    if (!file.existsSync()) {
      throw MediaException.fileNotFound(file.path);
    }

    final bytes = await file.readAsBytes();
    final basename = path.basename(file.path);
    final fileExtension = path.extension(file.path).toLowerCase();

    // Determine media type if not provided
    final mediaType = type ?? _inferMediaType(fileExtension);

    // Check file size
    if (bytes.length > mediaType.maxSizeBytes) {
      throw MediaException.fileSizeExceeded(
        bytes.length,
        mediaType.maxSizeBytes,
      );
    }

    // Use provided or inferred MIME type
    final fileMimeType = mimeType ?? _inferMimeType(fileExtension);

    // Check if mime type is supported
    if (!mediaType.supportsMimeType(fileMimeType)) {
      throw MediaException.unsupportedMediaType(fileMimeType);
    }

    return MediaFile(
      type: mediaType,
      bytes: bytes,
      mimeType: fileMimeType,
      filename: filename ?? basename,
    );
  }

  /// Creates a media file from a base64-encoded string.
  ///
  /// [base64Data] is the base64-encoded file content.
  /// [type] is the type of media.
  /// [mimeType] is the MIME type of the file.
  /// [filename] is the name of the file with extension.
  static MediaFile fromBase64(
    String base64Data, {
    required MediaType type,
    required String mimeType,
    required String filename,
  }) {
    try {
      final bytes = base64Decode(base64Data);

      // Check file size
      if (bytes.length > type.maxSizeBytes) {
        throw MediaException.fileSizeExceeded(
          bytes.length,
          type.maxSizeBytes,
        );
      }

      // Check if mime type is supported
      if (!type.supportsMimeType(mimeType)) {
        throw MediaException.unsupportedMediaType(mimeType);
      }

      return MediaFile(
        type: type,
        bytes: bytes,
        mimeType: mimeType,
        filename: filename,
      );
    } catch (e) {
      if (e is MediaException) rethrow;
      throw MediaException(
        code: 'invalid_base64',
        message: 'Invalid base64 data',
        originalException: e,
      );
    }
  }

  /// Creates a media file from a URL (without actually downloading it).
  ///
  /// Note: This creates a reference to a media file without content bytes.
  /// It's meant for use with URLs that the WhatsApp API can access directly.
  ///
  /// [url] is the URL of the media.
  /// [type] is the type of media (if null, will be inferred from URL extension).
  /// [mimeType] is the MIME type (if null, will be inferred from URL extension).
  /// [filename] is the name to use (if null, will use the URL's basename).
  static MediaFile fromUrl(
    String url, {
    MediaType? type,
    String? mimeType,
    String? filename,
  }) {
    try {
      final uri = Uri.parse(url);
      final basename = path.basename(uri.path);
      final fileExtension = path.extension(uri.path).toLowerCase();

      // Determine media type if not provided
      final mediaType = type ?? _inferMediaType(fileExtension);

      // Use provided or inferred MIME type
      final fileMimeType = mimeType ?? _inferMimeType(fileExtension);

      // Check if mime type is supported
      if (!mediaType.supportsMimeType(fileMimeType)) {
        throw MediaException.unsupportedMediaType(fileMimeType);
      }

      return MediaFile(
        type: mediaType,
        bytes: Uint8List(0), // Empty because we're not downloading
        mimeType: fileMimeType,
        filename: filename ?? basename,
      );
    } catch (e) {
      if (e is MediaException) rethrow;
      throw MediaException(
        code: 'invalid_url',
        message: 'Invalid URL for media file',
        originalException: e,
      );
    }
  }

  /// Gets the file size in bytes.
  int get size => bytes.length;

  /// Gets the file extension from the filename.
  String get extension => path.extension(filename).toLowerCase();

  /// Converts the file content to base64.
  String toBase64() => base64Encode(bytes);

  /// Infers media type from file extension.
  static MediaType _inferMediaType(String fileExtension) {
    final ext = fileExtension.toLowerCase();
    
    if (ext.isEmpty) {
      throw MediaException(
        code: 'unknown_media_type',
        message: 'Could not determine media type from empty extension',
      );
    }

    if (['.jpg', '.jpeg', '.png'].contains(ext)) {
      return MediaType.image;
    } else if (['.mp4', '.3gp'].contains(ext)) {
      return MediaType.video;
    } else if (['.mp3', '.aac', '.amr', '.ogg', '.opus'].contains(ext)) {
      return MediaType.audio;
    } else if (['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt', '.rtf', '.zip'].contains(ext)) {
      return MediaType.document;
    } else if (ext == '.webp') {
      return MediaType.sticker;
    } else {
      // Default to document for unknown extensions
      return MediaType.document;
    }
  }

  /// Infers MIME type from file extension.
  static String _inferMimeType(String fileExtension) {
    final ext = fileExtension.toLowerCase();
    
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      case '.3gp':
        return 'video/3gpp';
      case '.mp3':
        return 'audio/mpeg';
      case '.aac':
        return 'audio/aac';
      case '.amr':
        return 'audio/amr';
      case '.ogg':
        return 'audio/ogg';
      case '.opus':
        return 'audio/opus';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.ppt':
        return 'application/vnd.ms-powerpoint';
      case '.pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case '.txt':
        return 'text/plain';
      case '.rtf':
        return 'text/rtf';
      case '.zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }
}