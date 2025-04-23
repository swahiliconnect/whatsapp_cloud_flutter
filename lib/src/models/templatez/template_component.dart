import 'package:meta/meta.dart';

/// Types of template components.
enum ComponentType {
  /// Header component (text, image, document, or video)
  header,

  /// Body component with text and optional variables
  body,

  /// Footer component with text
  footer,

  /// Button component for interactive templates
  button,
}

/// Parameter types for template components.
enum ParameterType {
  /// Text parameter
  text,

  /// Currency parameter for displaying amounts
  currency,

  /// Date/time parameter
  dateTime,

  /// Image parameter for header
  image,

  /// Document parameter for header
  document,

  /// Video parameter for header
  video,
}

/// Base class for all template parameters.
@immutable
abstract class TemplateParameter {
  /// Type of the parameter
  final ParameterType type;

  /// Creates a new template parameter.
  ///
  /// [type] is the type of the parameter.
  const TemplateParameter({
    required this.type,
  });

  /// Converts the parameter to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson();

  /// Validates the parameter.
  ///
  /// Returns true if the parameter is valid, false otherwise.
  bool isValid();
}

/// Text parameter for templates.
@immutable
class TextParameter extends TemplateParameter {
  /// Text content
  final String text;

  /// Creates a new text parameter.
  ///
  /// [text] is the text content of the parameter.
  const TextParameter({
    required this.text,
  }) : super(
          type: ParameterType.text,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'text',
      'text': text,
    };
  }

  @override
  bool isValid() {
    return text.isNotEmpty;
  }
}

/// Currency parameter for templates.
@immutable
class CurrencyParameter extends TemplateParameter {
  /// Currency code (ISO 4217)
  final String currencyCode;

  /// Amount in the smallest currency unit (e.g., cents for USD)
  final int amount;

  /// Creates a new currency parameter.
  ///
  /// [currencyCode] is the ISO 4217 currency code.
  /// [amount] is the amount in the smallest currency unit.
  const CurrencyParameter({
    required this.currencyCode,
    required this.amount,
  }) : super(
          type: ParameterType.currency,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'currency',
      'currency': {
        'code': currencyCode,
        'amount': amount,
      },
    };
  }

  @override
  bool isValid() {
    return currencyCode.isNotEmpty && currencyCode.length == 3;
  }
}

/// Date/time parameter for templates.
@immutable
class DateTimeParameter extends TemplateParameter {
  /// DateTime value
  final DateTime datetime;

  /// Creates a new date/time parameter.
  ///
  /// [datetime] is the date and time value.
  const DateTimeParameter({
    required this.datetime,
  }) : super(
          type: ParameterType.dateTime,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'date_time',
      'date_time': {
        'fallback_value': datetime.toIso8601String(),
      },
    };
  }

  @override
  bool isValid() {
    return true;
  }
}

/// Image parameter for template headers.
@immutable
class ImageParameter extends TemplateParameter {
  /// URL of the image
  final String imageUrl;

  /// Creates a new image parameter.
  ///
  /// [imageUrl] is the URL of the image.
  const ImageParameter({
    required this.imageUrl,
  }) : super(
          type: ParameterType.image,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'image',
      'image': {
        'link': imageUrl,
      },
    };
  }

  @override
  bool isValid() {
    return imageUrl.isNotEmpty && Uri.tryParse(imageUrl) != null;
  }
}

/// Document parameter for template headers.
@immutable
class DocumentParameter extends TemplateParameter {
  /// URL of the document
  final String documentUrl;

  /// Optional filename to display
  final String? filename;

  /// Creates a new document parameter.
  ///
  /// [documentUrl] is the URL of the document.
  /// [filename] is an optional filename to display.
  const DocumentParameter({
    required this.documentUrl,
    this.filename,
  }) : super(
          type: ParameterType.document,
        );

  @override
  Map<String, dynamic> toJson() {
    final json = {
      'type': 'document',
      'document': {
        'link': documentUrl,
      },
    };

    if (filename != null && filename!.isNotEmpty) {
      (json['document'] as Map<String, dynamic>)['filename'] = filename;
    }

    return json;
  }

  @override
  bool isValid() {
    return documentUrl.isNotEmpty && Uri.tryParse(documentUrl) != null;
  }
}

/// Video parameter for template headers.
@immutable
class VideoParameter extends TemplateParameter {
  /// URL of the video
  final String videoUrl;

  /// Creates a new video parameter.
  ///
  /// [videoUrl] is the URL of the video.
  const VideoParameter({
    required this.videoUrl,
  }) : super(
          type: ParameterType.video,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'video',
      'video': {
        'link': videoUrl,
      },
    };
  }

  @override
  bool isValid() {
    return videoUrl.isNotEmpty && Uri.tryParse(videoUrl) != null;
  }
}

/// Component of a WhatsApp message template.
@immutable
class TemplateComponent {
  /// Type of the component
  final ComponentType type;

  /// Subtype of the component (optional)
  final String? subType;

  /// Index of the component (used for buttons)
  final int? index;

  /// Parameters for the component
  final List<TemplateParameter> parameters;

  /// Creates a new template component.
  ///
  /// [type] is the type of component.
  /// [subType] is an optional subtype.
  /// [index] is an optional index (required for buttons).
  /// [parameters] is the list of parameters for the component.
  const TemplateComponent({
    required this.type,
    this.subType,
    this.index,
    this.parameters = const [],
  });

  /// Converts the component to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'type': _componentTypeToString(type),
    };

    if (subType != null) {
      json['sub_type'] = subType;
    }

    if (index != null) {
      json['index'] = index;
    }

    if (parameters.isNotEmpty) {
      json['parameters'] = parameters.map((p) => p.toJson()).toList();
    }

    return json;
  }

  /// Validates the component.
  ///
  /// Returns true if the component is valid, false otherwise.
  bool isValid() {
    // Validate specific component types
    if (type == ComponentType.button && index == null) {
      return false;
    }

    // Validate all parameters
    for (final parameter in parameters) {
      if (!parameter.isValid()) {
        return false;
      }
    }

    return true;
  }

  /// Converts ComponentType enum to string for API.
  String _componentTypeToString(ComponentType type) {
    switch (type) {
      case ComponentType.header:
        return 'header';
      case ComponentType.body:
        return 'body';
      case ComponentType.footer:
        return 'footer';
      case ComponentType.button:
        return 'button';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TemplateComponent &&
        other.type == type &&
        other.subType == subType &&
        other.index == index &&
        _listEquals(other.parameters, parameters);
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => type.hashCode ^ subType.hashCode ^ index.hashCode ^ parameters.hashCode;
}