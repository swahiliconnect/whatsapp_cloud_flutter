import 'package:flutter/foundation.dart';

/// Types of template components
enum ComponentType {
  header,
  body,
  footer,
  button,
}

/// Extension to convert component type to string
extension ComponentTypeExtension on ComponentType {
  String get value {
    switch (this) {
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
}

/// Base class for template parameters
abstract class TemplateParameter {
  Map<String, dynamic> toJson();
}

/// Text parameter for templates
class TextParameter extends TemplateParameter {
  final String text;

  TextParameter({required this.text});

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};
}

/// Image parameter for templates
class ImageParameter extends TemplateParameter {
  final String link;

  ImageParameter({required this.link});

  @override
  Map<String, dynamic> toJson() => {'type': 'image', 'image': {'link': link}};
}

/// Video parameter for templates
class VideoParameter extends TemplateParameter {
  final String link;

  VideoParameter({required this.link});

  @override
  Map<String, dynamic> toJson() => {'type': 'video', 'video': {'link': link}};
}

/// Document parameter for templates
class DocumentParameter extends TemplateParameter {
  final String link;
  final String? filename;

  DocumentParameter({required this.link, this.filename});

  @override
  Map<String, dynamic> toJson() {
    final json = {'type': 'document', 'document': {'link': link}};
    if (filename != null) {
      (json['document'] as Map<String, dynamic>)['filename'] = filename;
    }
    return json;
  }
}

/// Template component for structured messages
class TemplateComponent {
  final ComponentType type;
  final List<TemplateParameter>? parameters;
  final String? index; // For button components
  final String? subType; // For button components

  TemplateComponent({
    required this.type,
    this.parameters,
    this.index,
    this.subType,
  });

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{'type': type.value};
    
    if (parameters != null && parameters!.isNotEmpty) {
      result['parameters'] = parameters!.map((p) => p.toJson()).toList();
    }
    
    if (index != null) {
      result['index'] = index;
    }
    
    if (subType != null) {
      result['sub_type'] = subType;
    }
    
    return result;
  }
}