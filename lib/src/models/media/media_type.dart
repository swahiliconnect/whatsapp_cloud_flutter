/// Supported media types for WhatsApp Cloud API.
enum MediaType {
  /// Image files (JPEG, PNG)
  image,

  /// Video files (MP4)
  video,

  /// Audio files (MP3, AAC, etc.)
  audio,

  /// Document files (PDF, Office, etc.)
  document,

  /// Sticker files (WebP)
  sticker,
}

/// Extension methods for MediaType enum.
extension MediaTypeExtension on MediaType {
  /// Converts MediaType to its string representation for the API.
  String get value {
    switch (this) {
      case MediaType.image:
        return 'image';
      case MediaType.video:
        return 'video';
      case MediaType.audio:
        return 'audio';
      case MediaType.document:
        return 'document';
      case MediaType.sticker:
        return 'sticker';
    }
  }

  /// Gets the MIME type for the media type.
  ///
  /// Returns null if there's no default MIME type.
  String? get defaultMimeType {
    switch (this) {
      case MediaType.image:
        return 'image/jpeg';
      case MediaType.video:
        return 'video/mp4';
      case MediaType.audio:
        return 'audio/mp3';
      case MediaType.document:
        return 'application/pdf';
      case MediaType.sticker:
        return 'image/webp';
    }
  }

  /// Gets the file extensions supported for this media type.
  List<String> get supportedExtensions {
    switch (this) {
      case MediaType.image:
        return ['.jpg', '.jpeg', '.png'];
      case MediaType.video:
        return ['.mp4', '.3gp'];
      case MediaType.audio:
        return ['.mp3', '.aac', '.amr', '.ogg', '.opus'];
      case MediaType.document:
        return [
          '.pdf', '.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx',
          '.txt', '.rtf', '.zip'
        ];
      case MediaType.sticker:
        return ['.webp'];
    }
  }

  /// Gets the maximum file size in bytes for this media type.
  int get maxSizeBytes {
    switch (this) {
      case MediaType.image:
        return 5 * 1024 * 1024; // 5MB
      case MediaType.video:
        return 16 * 1024 * 1024; // 16MB
      case MediaType.audio:
        return 16 * 1024 * 1024; // 16MB
      case MediaType.document:
        return 100 * 1024 * 1024; // 100MB
      case MediaType.sticker:
        return 500 * 1024; // 500KB
    }
  }

  /// Checks if the file extension is supported for this media type.
  bool supportsExtension(String fileExtension) {
    final normalizedExtension = fileExtension.toLowerCase().startsWith('.')
        ? fileExtension.toLowerCase()
        : '.${fileExtension.toLowerCase()}';
    return supportedExtensions.contains(normalizedExtension);
  }

  /// Checks if the MIME type is supported for this media type.
  bool supportsMimeType(String mimeType) {
    final normalized = mimeType.toLowerCase();
    
    switch (this) {
      case MediaType.image:
        return normalized.startsWith('image/');
      case MediaType.video:
        return normalized.startsWith('video/');
      case MediaType.audio:
        return normalized.startsWith('audio/');
      case MediaType.document:
        return normalized.startsWith('application/') ||
            normalized == 'text/plain' ||
            normalized == 'text/rtf';
      case MediaType.sticker:
        return normalized == 'image/webp';
    }
  }
}