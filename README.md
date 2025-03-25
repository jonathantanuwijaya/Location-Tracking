# Location Tracking Practice

A Flutter application for tracking user location in the background and calculating time spent at different geofence locations.

## Features

- Background location tracking service
- Geofence-based location detection
- Time tracking for different locations
- Clock in/out functionality
- Historical data viewing

## Project Architecture

The application follows a layered architecture with a repository pattern:

- **User Interface Layer**: Screens, widgets, and providers for state management
- **Service Layer**: Business logic services and background processing
- **Repository Layer**: Data access and persistence
- **Core Layer**: Interfaces, utilities, and constants

## Project Structure

```
lib/
├── core/                  # Core utilities, constants, and interfaces
│   ├── constants/         # Application constants 
│   ├── init/              # Application initialization
│   ├── interfaces/        # Interfaces for repository pattern
│   └── util/              # Utility classes and adapters
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
    ├── app_services/      # Application services
    │   ├── location_data_service.dart # Location data processing
    │   ├── location_service.dart # Location detection service
    │   └── location_storage_service.dart # Data persistence service
    ├── background/        # Background processing
    │   ├── background_service_handler.dart # Background service handler
    │   └── service_background.dart # Background service initialization
    ├── logic/             # Core business logic
    │   ├── background_track_logic.dart # Background tracking logic
    │   ├── location_tracking_logic.dart # Location tracking logic
    │   └── mappers_logic.dart # Data mapping logic
    └── repository/        # Data repositories
        ├── location_summary_repository.dart # Location summary updates
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
- **get_it**: ^7.6.7 - For dependency injection
- **mocktail**: ^1.0.4 - For creating test mocks
- **flutter_localizations** - For internationalization support

### Dev Dependencies

- **flutter_test** - For widget and unit testing
- **integration_test** - For integration testing
- **very_good_analysis**: ^6.0.0 - For code quality and linting

## Testing

The application includes multiple levels of testing:

### Unit Tests

Unit tests verify the functionality of individual components, particularly the service and repository layers.

```
test/
├── fixtures/              # Test fixtures and mock data
├── providers/             # Provider tests
├── screens/               # Widget tests for screens
└── services/              # Service and repository tests
```

### Widget Tests

Widget tests verify UI components and their integration with providers.

Key tests include:
- Main page navigation and tab switching
- Location time summary display
- Geofence data interaction
- Clock in/out functionality

### Integration Tests

Simple integration tests to verify app launch stability on both Android and iOS platforms.

```
integration_test/
└── app_test.dart          # Basic app launch tests
```

To run tests:

```bash
# Unit and widget tests
flutter test

# Integration tests (Android)
flutter test integration_test/app_test.dart -d android

# Integration tests (iOS)
flutter test integration_test/app_test.dart -d ios
```

## Repository Pattern

The application implements the repository pattern to separate data access logic from business logic:

- **Interfaces**: Define contracts for repositories and services
- **Repositories**: Implement data access and storage operations
- **Services**: Use repositories to perform business logic

This architecture makes the code more:
- **Testable**: Easy to mock dependencies for testing
- **Maintainable**: Clear separation of concerns
- **Extensible**: New data sources can be added by implementing interfaces

## Getting Started

1. Clone the repository
2. Ensure you have Flutter SDK version ^3.7.0 installed
3. Run `flutter pub get` to install dependencies
4. Ensure location permissions are properly set up in your device settings
5. Run the app using `flutter run`

> **Note:** This project requires Flutter SDK version ^3.7.0 or higher.
