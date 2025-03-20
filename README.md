# Location Tracking Practice

A Flutter application for tracking user location in the background and calculating time spent at different geofence locations.

## Features

- Background location tracking service
- Geofence-based location detection
- Time tracking for different locations
- Clock in/out functionality
- Historical data viewing

## Project Structure

```
lib/
├── core/                  # Core utilities and constants
│   ├── constants/         # Application constants
│   └── util/              # Utility classes and extensions
├── models/                # Data models
│   ├── geofence_data.dart # Geofence location model
│   ├── location_data.dart # Current location model
│   └── location_time_summary.dart # Time summary model
├── providers/             # State management
│   ├── clock_in_out/      # Clock in/out state
│   ├── history_time_summary/ # Historical data state
│   ├── location_time_summary/ # Current location summary state
│   └── main_tab_view/     # UI navigation state
├── screens/               # UI screens
│   ├── widgets/           # Reusable UI components
│   ├── clock_in_out_page.dart # Clock in/out screen
│   ├── location_time_summary_page.dart # Location summary screen
│   └── main_page.dart     # Main application screen
└── services/              # Business logic services
    ├── logic/             # Core business logic
    │   ├── background_service_manager.dart # Background service management
    │   ├── location_service.dart # Location detection service
    │   ├── location_storage_service.dart # Data persistence service
    │   └── service_background.dart # Background service initialization
    └── repository/        # Data repositories
        └── location_time_summary_repository.dart # Location data repository
```

## Dependencies

### Main Dependencies

- **flutter_background_service**: ^5.1.0 - For running location tracking in the background
- **geolocator**: ^13.0.3 - For accessing device location services
- **geocoding**: ^3.0.0 - For converting coordinates to addresses
- **hive** & **hive_flutter**: ^2.2.3, ^1.1.0 - For local data storage
- **provider**: ^6.1.2 - For state management
- **intl**: ^0.19.0 - For date and time formatting
- **path** & **path_provider**: ^1.9.1, ^2.1.5 - For file system operations

### Dev Dependencies

- **flutter_lints**: ^5.0.0 - For code quality
- **hive_generator**: ^2.0.1 - For Hive model generation

## How It Works

1. The application uses Flutter's background service to track the user's location even when the app is not in the foreground.
2. Geofence locations can be defined by the user and are stored locally using Hive.
3. The background service periodically checks the user's location and determines if they are within any defined geofence.
4. Time spent in each location is tracked and summarized.
5. Users can clock in/out to start/stop the tracking service.
6. Historical data can be viewed to see time spent at different locations over time.

## Getting Started

1. Clone the repository
2. Ensure you have Flutter 3.29.2 installed
3. Run `flutter pub get` to install dependencies
4. Ensure location permissions are properly set up in your device settings
5. Run the app using `flutter run`

> **Note:** This project was built using Flutter 3.29.2

## Platform Support

This application supports both Android and iOS platforms with appropriate configurations for background location tracking on each platform.
