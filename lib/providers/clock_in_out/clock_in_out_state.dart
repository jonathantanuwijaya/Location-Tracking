import 'package:tracking_practice/models/geofence_data.dart';

class ClockInOutState {
  ClockInOutState({required this.isClockedIn, required this.geofenceData});
  final bool isClockedIn;
  final List<GeofenceData> geofenceData;

  factory ClockInOutState.initial() =>
      ClockInOutState(isClockedIn: false, geofenceData: []);

  ClockInOutState copyWith({
    bool? isClockedIn,
    List<GeofenceData>? geofenceData,
  }) => ClockInOutState(
    isClockedIn: isClockedIn ?? this.isClockedIn,
    geofenceData: geofenceData ?? this.geofenceData,
  );
}
