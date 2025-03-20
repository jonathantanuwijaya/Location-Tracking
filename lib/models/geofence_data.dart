class GeofenceData {
  /// Creates a new [GeofenceData] instance
  GeofenceData({
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  /// Creates a [GeofenceData] from Json
  factory GeofenceData.fromJson(Map<String, dynamic> json) {
    return GeofenceData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      name: json['name'] as String,
    );
  }

  /// The latitude coordinate
  final double latitude;

  /// The longitude coordinate
  final double longitude;

  /// The location name
  final String name;

  /// Converts this geofence data to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
    };
  }
}
