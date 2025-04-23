import 'package:meta/meta.dart';

import 'message.dart';

/// Location message for sharing geographical coordinates via WhatsApp.
///
/// Allows sending a location with latitude, longitude, and optional name and address.
@immutable
class LocationMessage extends Message {
  /// Latitude coordinate (-90.0 to 90.0)
  final double latitude;

  /// Longitude coordinate (-180.0 to 180.0)
  final double longitude;

  /// Optional name of the location
  final String? name;

  /// Optional address of the location
  final String? address;

  /// Creates a new location message.
  ///
  /// [recipient] is the recipient's phone number in international format.
  /// [latitude] is the latitude coordinate (-90.0 to 90.0).
  /// [longitude] is the longitude coordinate (-180.0 to 180.0).
  /// [name] is an optional name for the location.
  /// [address] is an optional address for the location.
  const LocationMessage({
    required String recipient,
    required this.latitude,
    required this.longitude,
    this.name,
    this.address,
  }) : super(
          type: MessageType.location,
          recipient: recipient,
        );

  @override
  bool isValid() {
    // Validate latitude and longitude ranges
    return latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }

  @override
  Map<String, dynamic> toJson() {
    final messageMap = createBaseMessageMap();
    
    messageMap['type'] = 'location';
    messageMap['location'] = {
      'latitude': latitude,
      'longitude': longitude,
    };
    
    // Add optional fields if provided
    if (name != null && name!.isNotEmpty) {
      messageMap['location']['name'] = name;
    }
    
    if (address != null && address!.isNotEmpty) {
      messageMap['location']['address'] = address;
    }
    
    return messageMap;
  }

  @override
  List<Object?> get props => [...super.props, latitude, longitude, name, address];

  /// Creates a copy of this message with the given fields replaced.
  LocationMessage copyWith({
    String? recipient,
    double? latitude,
    double? longitude,
    String? name,
    String? address,
  }) {
    return LocationMessage(
      recipient: recipient ?? this.recipient,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }
}