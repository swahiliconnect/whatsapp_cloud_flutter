import 'package:meta/meta.dart';

import 'template_component.dart';

/// Status of a WhatsApp message template.
enum TemplateStatus {
  /// Template is approved and ready to use
  approved,

  /// Template is pending review
  pending,

  /// Template was rejected
  rejected,

  /// Template is disabled
  disabled,
}

/// Message template for WhatsApp Cloud API.
///
/// Templates allow sending structured messages that have been pre-approved
/// by WhatsApp. This is the primary way to initiate conversations.
@immutable
class Template {
  /// Template name as registered in the WhatsApp Business Manager
  final String name;

  /// Language code for the template
  final String language;

  /// List of components that make up the template
  final List<TemplateComponent> components;

  /// Creates a new template message.
  ///
  /// [name] is the template name as registered in the WhatsApp Business Manager.
  /// [language] is the language code for the template (e.g., "en_US").
  /// [components] is the list of components that make up the template.
  const Template({
    required this.name,
    required this.language,
    this.components = const [],
  });

  /// Validates the template for use.
  ///
  /// Returns true if the template is valid, false otherwise.
  bool isValid() {
    // Check required fields
    if (name.isEmpty || language.isEmpty) {
      return false;
    }

    // Validate all components
    for (final component in components) {
      if (!component.isValid()) {
        return false;
      }
    }

    return true;
  }

  /// Converts the template to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'language': {'code': language},
    };

    if (components.isNotEmpty) {
      json['components'] = components.map((c) => c.toJson()).toList();
    }

    return json;
  }

  /// Creates a copy of this template with the given fields replaced.
  Template copyWith({
    String? name,
    String? language,
    List<TemplateComponent>? components,
  }) {
    return Template(
      name: name ?? this.name,
      language: language ?? this.language,
      components: components ?? this.components,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Template &&
        other.name == name &&
        other.language == language &&
        _listEquals(other.components, components);
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
  int get hashCode => name.hashCode ^ language.hashCode ^ components.hashCode;
}

/// Helper class for creating message templates.
class TemplateBuilder {
  /// Template name
  final String name;

  /// Language code
  final String language;

  /// Template components
  final List<TemplateComponent> _components = [];

  /// Creates a new template builder.
  ///
  /// [name] is the template name.
  /// [language] is the language code for the template.
  TemplateBuilder({
    required this.name,
    required this.language,
  });

  /// Adds a header component to the template.
  ///
  /// [parameters] is the list of parameters for the header.
  /// Returns this builder for method chaining.
  TemplateBuilder withHeader(List<TemplateParameter> parameters) {
    _components.add(TemplateComponent(
      type: ComponentType.header,
      parameters: parameters,
    ));
    return this;
  }

  /// Adds a body component to the template.
  ///
  /// [parameters] is the list of parameters for the body.
  /// Returns this builder for method chaining.
  TemplateBuilder withBody(List<TemplateParameter> parameters) {
    _components.add(TemplateComponent(
      type: ComponentType.body,
      parameters: parameters,
    ));
    return this;
  }

  /// Adds a footer component to the template.
  ///
  /// [parameters] is the list of parameters for the footer.
  /// Returns this builder for method chaining.
  TemplateBuilder withFooter(List<TemplateParameter> parameters) {
    _components.add(TemplateComponent(
      type: ComponentType.footer,
      parameters: parameters,
    ));
    return this;
  }

  /// Adds a button component to the template.
  ///
  /// [index] is the index of the button.
  /// [parameters] is the list of parameters for the button.
  /// Returns this builder for method chaining.
  TemplateBuilder withButton(int index, List<TemplateParameter> parameters) {
    _components.add(TemplateComponent(
      type: ComponentType.button,
      subType: 'button',
      index: index,
      parameters: parameters,
    ));
    return this;
  }

  /// Builds the final template.
  ///
  /// Returns a Template instance with all added components.
  Template build() {
    return Template(
      name: name,
      language: language,
      components: List.from(_components),
    );
  }
}