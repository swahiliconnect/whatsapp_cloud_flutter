import 'package:meta/meta.dart';

import 'message.dart';

/// Media source options for media messages.
enum MediaSource {
  /// Media is identified by its ID
  id,

  /// Media is accessed via a URL
  url,
}

/// Base class for all media-based message types.
///
/// Handles common functionality for image, video, audio, document, and sticker messages.
@immutable
abstract class MediaMessage extends Message {
  /// Media source type (ID or URL)
  final MediaSource source;

  /// Media ID if source is ID
  final String? mediaId;

  /// Media URL if source is URL
  final String? mediaUrl;

  /// Optional caption for the media
  final String? caption;

  /// Creates a new media message.
  ///
  /// [type] is the specific media message type.
  /// [recipient] is the recipient's phone number in international format.
  /// [source] specifies whether the media is identified by ID or URL.
  /// [mediaId] is the ID of the media (required if source is ID).
  /// [mediaUrl] is the URL of the media (required if source is URL).
  /// [caption] is an optional text caption for the media.
  const MediaMessage({
    required MessageType type,
    required String recipient,
    required this.source,
    this.mediaId,
    this.mediaUrl,
    this.caption,
  }) : super(
          type: type,
          recipient: recipient,
        );

  @override
  bool isValid() {
    // Check for required fields based on source
    if (source == MediaSource.id && (mediaId == null || mediaId!.isEmpty)) {
      return false;
    }
    
    if (source == MediaSource.url && (mediaUrl == null || mediaUrl!.isEmpty)) {
      return false;
    }
    
    // Check caption length if present
    if (caption != null && caption!.length > 1024) {
      return false;
    }
    
    return true;
  }

  @override
  List<Object?> get props => [...super.props, source, mediaId, mediaUrl, caption];

  /// Gets the media type string for the API request.
  @protected
  String getMediaTypeString();

  @override
  Map<String, dynamic> toJson() {
    final messageMap = createBaseMessageMap();
    final mediaTypeString = getMediaTypeString();
    
    messageMap['type'] = mediaTypeString;
    
    final mediaObject = <String, dynamic>{};
    
    // Add media identifier based on source
    if (source == MediaSource.id) {
      mediaObject['id'] = mediaId;
    } else {
      mediaObject['link'] = mediaUrl;
    }
    
    // Add caption if available
    if (caption != null && caption!.isNotEmpty) {
      mediaObject['caption'] = caption;
    }
    
    messageMap[mediaTypeString] = mediaObject;
    
    return messageMap;
  }
}

/// Image message for sending images via WhatsApp.
@immutable
class ImageMessage extends MediaMessage {
  /// Creates a new image message.
  ///
  /// [recipient] is the recipient's phone number in international format.
  /// [source] specifies whether the image is identified by ID or URL.
  /// [mediaId] is the ID of the image (required if source is ID).
  /// [mediaUrl] is the URL of the image (required if source is URL).
  /// [caption] is an optional text caption for the image.
  const ImageMessage({
    required String recipient,
    required MediaSource source,
    String? mediaId,
    String? mediaUrl,
    String? caption,
  }) : super(
          type: MessageType.image,
          recipient: recipient,
          source: source,
          mediaId: mediaId,
          mediaUrl: mediaUrl,
          caption: caption,
        );

  @override
  String getMediaTypeString() => 'image';

  /// Creates a copy of this message with the given fields replaced.
  ImageMessage copyWith({
    String? recipient,
    MediaSource? source,
    String? mediaId,
    String? mediaUrl,
    String? caption,
  }) {
    return ImageMessage(
      recipient: recipient ?? this.recipient,
      source: source ?? this.source,
      mediaId: mediaId ?? this.mediaId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
    );
  }
}

/// Video message for sending videos via WhatsApp.
@immutable
class VideoMessage extends MediaMessage {
  /// Creates a new video message.
  ///
  /// [recipient] is the recipient's phone number in international format.
  /// [source] specifies whether the video is identified by ID or URL.
  /// [mediaId] is the ID of the video (required if source is ID).
  /// [mediaUrl] is the URL of the video (required if source is URL).
  /// [caption] is an optional text caption for the video.
  const VideoMessage({
    required String recipient,
    required MediaSource source,
    String? mediaId,
    String? mediaUrl,
    String? caption,
  }) : super(
          type: MessageType.video,
          recipient: recipient,
          source: source,
          mediaId: mediaId,
          mediaUrl: mediaUrl,
          caption: caption,
        );

  @override
  String getMediaTypeString() => 'video';

  /// Creates a copy of this message with the given fields replaced.
  VideoMessage copyWith({
    String? recipient,
    MediaSource? source,
    String? mediaId,
    String? mediaUrl,
    String? caption,
  }) {
    return VideoMessage(
      recipient: recipient ?? this.recipient,
      source: source ?? this.source,
      mediaId: mediaId ?? this.mediaId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
    );
  }
}

/// Audio message for sending audio files via WhatsApp.
@immutable
class AudioMessage extends MediaMessage {
  /// Creates a new audio message.
  ///
  /// [recipient] is the recipient's phone number in international format.
  /// [source] specifies whether the audio is identified by ID or URL.
  /// [mediaId] is the ID of the audio (required if source is ID).
  /// [mediaUrl] is the URL of the audio (required if source is URL).
  const AudioMessage({
    required String recipient,
    required MediaSource source,
    String? mediaId,
    String? mediaUrl,
  }) : super(
          type: MessageType.audio,
          recipient: recipient,
          source: source,
          mediaId: mediaId,
          mediaUrl: mediaUrl,
          // Note: Audio messages don't support captions
          caption: null,
        );

  @override
  String getMediaTypeString() => 'audio';

  /// Creates a copy of this message with the given fields replaced.
  AudioMessage copyWith({
    String? recipient,
    MediaSource? source,
    String? mediaId,
    String? mediaUrl,
  }) {
    return AudioMessage(
      recipient: recipient ?? this.recipient,
      source: source ?? this.source,
      mediaId: mediaId ?? this.mediaId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }
}

/// Document message for sending files via WhatsApp.
@immutable
class DocumentMessage extends MediaMessage {
  /// Filename to display for the document
  final String? filename;

  /// Creates a new document message.
  ///
  /// [recipient] is the recipient's phone number in international format.
  /// [source] specifies whether the document is identified by ID or URL.
  /// [mediaId] is the ID of the document (required if source is ID).
  /// [mediaUrl] is the URL of the document (required if source is URL).
  /// [caption] is an optional text caption for the document.
  /// [filename] is an optional filename to display for the document.
  const DocumentMessage({
    required String recipient,
    required MediaSource source,
    String? mediaId,
    String? mediaUrl,
    String? caption,
    this.filename,
  }) : super(
          type: MessageType.document,
          recipient: recipient,
          source: source,
          mediaId: mediaId,
          mediaUrl: mediaUrl,
          caption: caption,
        );

  @override
  String getMediaTypeString() => 'document';

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    
    // Add filename if provided
    if (filename != null && filename!.isNotEmpty) {
      (map['document'] as Map<String, dynamic>)['filename'] = filename;
    }
    
    return map;
  }

  @override
  List<Object?> get props => [...super.props, filename];

  /// Creates a copy of this message with the given fields replaced.
  DocumentMessage copyWith({
    String? recipient,
    MediaSource? source,
    String? mediaId,
    String? mediaUrl,
    String? caption,
    String? filename,
  }) {
    return DocumentMessage(
      recipient: recipient ?? this.recipient,
      source: source ?? this.source,
      mediaId: mediaId ?? this.mediaId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      filename: filename ?? this.filename,
    );
  }
}

/// Sticker message for sending stickers via WhatsApp.
@immutable
class StickerMessage extends MediaMessage {
  /// Creates a new sticker message.
  ///
  /// [recipient] is the recipient's phone number in international format.
  /// [source] specifies whether the sticker is identified by ID or URL.
  /// [mediaId] is the ID of the sticker (required if source is ID).
  /// [mediaUrl] is the URL of the sticker (required if source is URL).
  const StickerMessage({
    required String recipient,
    required MediaSource source,
    String? mediaId,
    String? mediaUrl,
  }) : super(
          type: MessageType.sticker,
          recipient: recipient,
          source: source,
          mediaId: mediaId,
          mediaUrl: mediaUrl,
          // Note: Sticker messages don't support captions
          caption: null,
        );

  @override
  String getMediaTypeString() => 'sticker';

  /// Creates a copy of this message with the given fields replaced.
  StickerMessage copyWith({
    String? recipient,
    MediaSource? source,
    String? mediaId,
    String? mediaUrl,
  }) {
    return StickerMessage(
      recipient: recipient ?? this.recipient,
      source: source ?? this.source,
      mediaId: mediaId ?? this.mediaId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }
}