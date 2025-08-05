import 'package:meta/meta.dart';

import 'message.dart';

/// Types of interactive messages supported by WhatsApp Cloud API.
enum InteractiveType {
  /// Button-based interactive message
  button,

  /// List-based interactive message
  list,

  /// Product-based interactive message
  product,

  /// Product list interactive message
  productList,
}

/// Interactive message component types.
enum InteractiveComponentType {
  /// Header component
  header,

  /// Body component
  body,

  /// Footer component
  footer,

  /// Action component
  action,
}

/// Base class for interactive message components.
@immutable
abstract class InteractiveComponent {
  /// The type of component
  final InteractiveComponentType type;

  /// Creates a new interactive component.
  ///
  /// [type] is the type of component.
  const InteractiveComponent({
    required this.type,
  });

  /// Converts the component to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson();
}

/// Header component for interactive messages.
@immutable
class HeaderComponent extends InteractiveComponent {
  /// Header text content
  final String text;

  /// Creates a new header component.
  ///
  /// [text] is the header text content (max 60 characters).
  const HeaderComponent({
    required this.text,
  }) : super(
          type: InteractiveComponentType.header,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'text',
      'text': text,
    };
  }
}

/// Body component for interactive messages.
@immutable
class BodyComponent extends InteractiveComponent {
  /// Body text content
  final String text;

  /// Creates a new body component.
  ///
  /// [text] is the body text content (max 1024 characters).
  const BodyComponent({
    required this.text,
  }) : super(
          type: InteractiveComponentType.body,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}

/// Footer component for interactive messages.
@immutable
class FooterComponent extends InteractiveComponent {
  /// Footer text content
  final String text;

  /// Creates a new footer component.
  ///
  /// [text] is the footer text content (max 60 characters).
  const FooterComponent({
    required this.text,
  }) : super(
          type: InteractiveComponentType.footer,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}

/// Button component for interactive button messages.
@immutable
class Button {
  /// Button type (typically "reply")
  final String type;

  /// Button title
  final String title;

  /// Button identifier
  final String id;

  /// Creates a new button.
  ///
  /// [type] is the button type (default is "reply").
  /// [title] is the button title text (max 20 characters).
  /// [id] is the button identifier (max 256 characters).
  const Button({
    this.type = 'reply',
    required this.title,
    required this.id,
  });

  /// Converts the button to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'reply': {
        'title': title,
        'id': id,
      },
    };
  }
}

/// Action component for button-based interactive messages.
@immutable
class ButtonActionComponent extends InteractiveComponent {
  /// List of buttons to display
  final List<Button> buttons;

  /// Creates a new button action component.
  ///
  /// [buttons] is the list of buttons to display (max 3).
  const ButtonActionComponent({
    required this.buttons,
  }) : super(
          type: InteractiveComponentType.action,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'buttons': buttons.map((button) => button.toJson()).toList(),
    };
  }
}

/// Section for list-based interactive messages.
@immutable
class Section {
  /// Section title
  final String title;

  /// List of rows in the section
  final List<Row> rows;

  /// Creates a new section.
  ///
  /// [title] is the section title (max 24 characters).
  /// [rows] is the list of rows in the section.
  const Section({
    required this.title,
    required this.rows,
  });

  /// Converts the section to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'rows': rows.map((row) => row.toJson()).toList(),
    };
  }
}

/// Row item for list-based interactive messages.
@immutable
class Row {
  /// Row identifier
  final String id;

  /// Row title
  final String title;

  /// Optional row description
  final String? description;

  /// Creates a new row.
  ///
  /// [id] is the row identifier (max 200 characters).
  /// [title] is the row title (max 24 characters).
  /// [description] is an optional row description (max 72 characters).
  const Row({
    required this.id,
    required this.title,
    this.description,
  });

  /// Converts the row to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'title': title,
    };
    
    if (description != null && description!.isNotEmpty) {
      json['description'] = description;
    }
    
    return json;
  }
}

/// Action component for list-based interactive messages.
@immutable
class ListActionComponent extends InteractiveComponent {
  /// Button text for opening the list
  final String buttonText;

  /// List of sections
  final List<Section> sections;

  /// Creates a new list action component.
  ///
  /// [buttonText] is the text for the button that opens the list (max 20 characters).
  /// [sections] is the list of sections to display.
  const ListActionComponent({
    required this.buttonText,
    required this.sections,
  }) : super(
          type: InteractiveComponentType.action,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'button': buttonText,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }
}

/// Interactive message for creating clickable button or list messages.
@immutable
class InteractiveMessage extends Message {
  /// Type of interactive message
  final InteractiveType interactiveType;

  /// Header component (optional)
  final HeaderComponent? header;

  /// Body component (required)
  final BodyComponent body;

  /// Footer component (optional)
  final FooterComponent? footer;

  /// Action component (required)
  final InteractiveComponent action;

  /// Creates a new interactive message.
  ///
  /// [recipient] is the recipient's phone number in international format.
  /// [interactiveType] is the type of interactive message.
  /// [body] is the required body component.
  /// [action] is the required action component.
  /// [header] is an optional header component.
  /// [footer] is an optional footer component.
  const InteractiveMessage({
    required String recipient,
    required this.interactiveType,
    required this.body,
    required this.action,
    this.header,
    this.footer,
  }) : super(
          type: MessageType.interactive,
          recipient: recipient,
        );

  @override
  bool isValid() {
    // Check if the action type matches the interactive type
    if (interactiveType == InteractiveType.button &&
        action is! ButtonActionComponent) {
      return false;
    }
    
    if (interactiveType == InteractiveType.list &&
        action is! ListActionComponent) {
      return false;
    }
    
    // Button validation
    if (interactiveType == InteractiveType.button) {
      final buttonAction = action as ButtonActionComponent;
      if (buttonAction.buttons.length > 3) {
        return false;
      }
    }
    
    // List validation
    if (interactiveType == InteractiveType.list) {
      final listAction = action as ListActionComponent;
      if (listAction.sections.length > 10) {
        return false;
      }
      
      // Check total number of items across all sections
      int totalItems = 0;
      for (final section in listAction.sections) {
        totalItems += section.rows.length;
      }
      
      if (totalItems > 10) {
        return false;
      }
    }
    
    return true;
  }

  @override
  Map<String, dynamic> toJson() {
    final messageMap = createBaseMessageMap();
    
    messageMap['type'] = 'interactive';
    
    final interactive = <String, dynamic>{
      'type': _interactiveTypeToString(interactiveType),
      'body': body.toJson(),
    };
    
    // Add optional components if present
    if (header != null) {
      interactive['header'] = header!.toJson();
    }
    
    if (footer != null) {
      interactive['footer'] = footer!.toJson();
    }
    
    interactive['action'] = action.toJson();
    
    messageMap['interactive'] = interactive;
    
    return messageMap;
  }

  /// Converts interactive type enum to string for API.
  String _interactiveTypeToString(InteractiveType type) {
    switch (type) {
      case InteractiveType.button:
        return 'button';
      case InteractiveType.list:
        return 'list';
      case InteractiveType.product:
        return 'product';
      case InteractiveType.productList:
        return 'product_list';
    }
  }

  @override
  List<Object?> get props => [
        ...super.props,
        interactiveType,
        header,
        body,
        footer,
        action,
      ];

  /// Creates a copy of this message with the given fields replaced.
  InteractiveMessage copyWith({
    String? recipient,
    InteractiveType? interactiveType,
    BodyComponent? body,
    InteractiveComponent? action,
    HeaderComponent? header,
    FooterComponent? footer,
  }) {
    return InteractiveMessage(
      recipient: recipient ?? this.recipient,
      interactiveType: interactiveType ?? this.interactiveType,
      body: body ?? this.body,
      action: action ?? this.action,
      header: header ?? this.header,
      footer: footer ?? this.footer,
    );
  }
}

/// Factory methods for creating common interactive messages.
class InteractiveMessageFactory {
  /// Creates a button-based interactive message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [bodyText] is the main message text.
  /// [buttons] is the list of buttons to display.
  /// [headerText] is optional text for the header.
  /// [footerText] is optional text for the footer.
  static InteractiveMessage createButtonMessage({
    required String recipient,
    required String bodyText,
    required List<Button> buttons,
    String? headerText,
    String? footerText,
  }) {
    return InteractiveMessage(
      recipient: recipient,
      interactiveType: InteractiveType.button,
      body: BodyComponent(text: bodyText),
      action: ButtonActionComponent(buttons: buttons),
      header: headerText != null ? HeaderComponent(text: headerText) : null,
      footer: footerText != null ? FooterComponent(text: footerText) : null,
    );
  }

  /// Creates a list-based interactive message.
  ///
  /// [recipient] is the recipient's phone number.
  /// [bodyText] is the main message text.
  /// [buttonText] is the text for the button that opens the list.
  /// [sections] is the list of sections to display.
  /// [headerText] is optional text for the header.
  /// [footerText] is optional text for the footer.
  static InteractiveMessage createListMessage({
    required String recipient,
    required String bodyText,
    required String buttonText,
    required List<Section> sections,
    String? headerText,
    String? footerText,
  }) {
    return InteractiveMessage(
      recipient: recipient,
      interactiveType: InteractiveType.list,
      body: BodyComponent(text: bodyText),
      action: ListActionComponent(
        buttonText: buttonText,
        sections: sections,
      ),
      header: headerText != null ? HeaderComponent(text: headerText) : null,
      footer: footerText != null ? FooterComponent(text: footerText) : null,
    );
  }
}