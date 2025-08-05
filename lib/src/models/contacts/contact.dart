import 'package:meta/meta.dart';

/// Contact address information.
@immutable
class Address {
  /// Street address
  final String? street;

  /// City
  final String? city;

  /// State
  final String? state;

  /// ZIP code
  final String? zip;

  /// Country
  final String? country;

  /// Country code
  final String? countryCode;

  /// Type of address (e.g., HOME, WORK)
  final String? type;

  /// Creates a new address.
  ///
  /// [street] is the street address.
  /// [city] is the city.
  /// [state] is the state or province.
  /// [zip] is the ZIP or postal code.
  /// [country] is the country name.
  /// [countryCode] is the two-letter country code.
  /// [type] is the type of address (e.g., HOME, WORK).
  const Address({
    this.street,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.countryCode,
    this.type,
  });

  /// Checks if the address has any data.
  ///
  /// Returns true if at least one field has a value.
  bool get hasData => street != null ||
      city != null ||
      state != null ||
      zip != null ||
      country != null ||
      countryCode != null;

  /// Converts the address to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> address = {
      'type': type ?? 'HOME',
    };

    final params = <String, dynamic>{};

    if (street != null && street!.isNotEmpty) {
      params['street'] = street;
    }

    if (city != null && city!.isNotEmpty) {
      params['city'] = city;
    }

    if (state != null && state!.isNotEmpty) {
      params['state'] = state;
    }

    if (zip != null && zip!.isNotEmpty) {
      params['zip'] = zip;
    }

    if (country != null && country!.isNotEmpty) {
      params['country'] = country;
    }

    if (countryCode != null && countryCode!.isNotEmpty) {
      params['country_code'] = countryCode;
    }

    address['params'] = params;
    return address;
  }
}

/// Email information for a contact.
@immutable
class Email {
  /// Email address
  final String email;

  /// Type of email (e.g., HOME, WORK)
  final String? type;

  /// Creates a new email.
  ///
  /// [email] is the email address.
  /// [type] is the type of email (e.g., HOME, WORK).
  const Email({
    required this.email,
    this.type,
  });

  /// Converts the email to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'type': type ?? 'HOME',
    };
  }
}

/// Phone information for a contact.
@immutable
class Phone {
  /// Phone number
  final String phone;

  /// Type of phone (e.g., CELL, HOME, WORK)
  final String? type;

  /// Phone number country code
  final String? waId;

  /// Creates a new phone.
  ///
  /// [phone] is the phone number.
  /// [type] is the type of phone (e.g., CELL, HOME, WORK).
  /// [waId] is the WhatsApp ID (country code + phone number).
  const Phone({
    required this.phone,
    this.type,
    this.waId,
  });

  /// Converts the phone to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'phone': phone,
      'type': type ?? 'CELL',
    };

    if (waId != null && waId!.isNotEmpty) {
      json['wa_id'] = waId;
    }

    return json;
  }
}

/// URL information for a contact.
@immutable
class Url {
  /// URL value
  final String url;

  /// Type of URL (e.g., HOME, WORK)
  final String? type;

  /// Creates a new URL.
  ///
  /// [url] is the URL value.
  /// [type] is the type of URL (e.g., HOME, WORK).
  const Url({
    required this.url,
    this.type,
  });

  /// Converts the URL to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type ?? 'HOME',
    };
  }
}

/// Contact information for WhatsApp messages.
///
/// Used for sharing contacts via WhatsApp messages.
@immutable
class Contact {
  /// First name
  final String? firstName;

  /// Last name
  final String? lastName;

  /// Middle name
  final String? middleName;

  /// Name prefix (e.g., Dr., Mr., Mrs.)
  final String? namePrefix;

  /// Name suffix (e.g., Jr., Sr., MD)
  final String? nameSuffix;

  /// Formatted name
  final String? formattedName;

  /// Company
  final String? company;

  /// Department
  final String? department;

  /// Title
  final String? title;

  /// Addresses
  final List<Address> addresses;

  /// Emails
  final List<Email> emails;

  /// Phones
  final List<Phone> phones;

  /// URLs
  final List<Url> urls;

  /// Birthday in YYYY-MM-DD format
  final String? birthday;

  /// Creates a new contact.
  ///
  /// [firstName] is the first name.
  /// [lastName] is the last name.
  /// [middleName] is the middle name.
  /// [namePrefix] is the name prefix (e.g., Dr., Mr., Mrs.).
  /// [nameSuffix] is the name suffix (e.g., Jr., Sr., MD).
  /// [formattedName] is the formatted name (required if firstName is not provided).
  /// [company] is the company name.
  /// [department] is the department within the company.
  /// [title] is the job title.
  /// [addresses] is the list of addresses.
  /// [emails] is the list of emails.
  /// [phones] is the list of phones.
  /// [urls] is the list of URLs.
  /// [birthday] is the birthday in YYYY-MM-DD format.
  const Contact({
    this.firstName,
    this.lastName,
    this.middleName,
    this.namePrefix,
    this.nameSuffix,
    this.formattedName,
    this.company,
    this.department,
    this.title,
    this.addresses = const [],
    this.emails = const [],
    this.phones = const [],
    this.urls = const [],
    this.birthday,
  });

  /// Validates the contact.
  ///
  /// Returns true if the contact is valid, false otherwise.
  bool isValid() {
    // Either firstName or formattedName must be provided
    if ((firstName == null || firstName!.isEmpty) &&
        (formattedName == null || formattedName!.isEmpty)) {
      return false;
    }

    // At least one phone number is required
    if (phones.isEmpty) {
      return false;
    }

    return true;
  }

  /// Converts the contact to a JSON-serializable map.
  ///
  /// Returns a map that can be serialized to JSON for the API request.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    // Name is required
    final nameData = <String, dynamic>{};

    if (firstName != null && firstName!.isNotEmpty) {
      nameData['first_name'] = firstName;
    }

    if (lastName != null && lastName!.isNotEmpty) {
      nameData['last_name'] = lastName;
    }

    if (middleName != null && middleName!.isNotEmpty) {
      nameData['middle_name'] = middleName;
    }

    if (namePrefix != null && namePrefix!.isNotEmpty) {
      nameData['prefix'] = namePrefix;
    }

    if (nameSuffix != null && nameSuffix!.isNotEmpty) {
      nameData['suffix'] = nameSuffix;
    }

    if (formattedName != null && formattedName!.isNotEmpty) {
      nameData['formatted_name'] = formattedName;
    } else {
      // If formatted name is not provided, generate it from first and last name
      nameData['formatted_name'] =
          [namePrefix, firstName, middleName, lastName, nameSuffix]
              .where((name) => name != null && name.isNotEmpty)
              .join(' ');
    }

    json['name'] = nameData;

    // Add organization if any of the fields are set
    if ((company != null && company!.isNotEmpty) ||
        (department != null && department!.isNotEmpty) ||
        (title != null && title!.isNotEmpty)) {
      final organizationData = <String, dynamic>{};

      if (company != null && company!.isNotEmpty) {
        organizationData['company'] = company;
      }

      if (department != null && department!.isNotEmpty) {
        organizationData['department'] = department;
      }

      if (title != null && title!.isNotEmpty) {
        organizationData['title'] = title;
      }

      json['org'] = organizationData;
    }

    // Add phones, emails, addresses, URLs if present
    if (phones.isNotEmpty) {
      json['phones'] = phones.map((phone) => phone.toJson()).toList();
    }

    if (emails.isNotEmpty) {
      json['emails'] = emails.map((email) => email.toJson()).toList();
    }

    if (addresses.isNotEmpty) {
      final validAddresses =
          addresses.where((address) => address.hasData).toList();
      if (validAddresses.isNotEmpty) {
        json['addresses'] =
            validAddresses.map((address) => address.toJson()).toList();
      }
    }

    if (urls.isNotEmpty) {
      json['urls'] = urls.map((url) => url.toJson()).toList();
    }

    // Add birthday if present
    if (birthday != null && birthday!.isNotEmpty) {
      json['birthday'] = birthday;
    }

    return json;
  }

  /// Creates a copy of this contact with the given fields replaced.
  Contact copyWith({
    String? firstName,
    String? lastName,
    String? middleName,
    String? namePrefix,
    String? nameSuffix,
    String? formattedName,
    String? company,
    String? department,
    String? title,
    List<Address>? addresses,
    List<Email>? emails,
    List<Phone>? phones,
    List<Url>? urls,
    String? birthday,
  }) {
    return Contact(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      namePrefix: namePrefix ?? this.namePrefix,
      nameSuffix: nameSuffix ?? this.nameSuffix,
      formattedName: formattedName ?? this.formattedName,
      company: company ?? this.company,
      department: department ?? this.department,
      title: title ?? this.title,
      addresses: addresses ?? this.addresses,
      emails: emails ?? this.emails,
      phones: phones ?? this.phones,
      urls: urls ?? this.urls,
      birthday: birthday ?? this.birthday,
    );
  }
}