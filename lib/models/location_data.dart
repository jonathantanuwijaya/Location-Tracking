import 'package:geolocator/geolocator.dart';

/// Model class representing location data
class LocationData {
  /// Creates a new [LocationData] instance
  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.name,
  });

  /// Creates a [LocationData] from Json
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      name: json['name'] as String,
    );
  }

  /// Creates a [LocationData] from a Geolocator [Position]
  factory LocationData.fromPosition(Position position, String name) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
      name: name,
    );
  }

  /// The latitude coordinate
  final double latitude;

  /// The longitude coordinate
  final double longitude;

  /// Timestamp when the location was recorded
  final DateTime timestamp;

  /// Location name
  final String name;

  /// Converts this location data to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'name': name,
    };
  }
}
