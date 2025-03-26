import 'package:geolocator/geolocator.dart';

class GeofenceData {
  GeofenceData({
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  factory GeofenceData.fromJson(Map<String, dynamic> json) {
    return GeofenceData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      name: json['name'] as String,
    );
  }
  factory GeofenceData.fromPosition(Position position, String name) {
    return GeofenceData(
      latitude: position.latitude,
      longitude: position.longitude,
      name: name,
    );
  }

  final double latitude;

  final double longitude;

  final String name;

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude, 'name': name};
  }
}
