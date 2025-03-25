#!/bin/bash

# Ensure script fails if any command fails
set -e

echo "Flutter Integration Test Runner"
echo "=============================="

# Default parameters
PLATFORM="android"
MODE="comprehensive" # Updated default mode

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--platform) PLATFORM="$2"; shift ;;
        -m|--mode) MODE="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate platform
if [[ "$PLATFORM" != "android" && "$PLATFORM" != "ios" ]]; then
    echo "Error: Platform must be 'android' or 'ios'"
    exit 1
fi

# Validate mode
if [[ "$MODE" != "minimal" && "$MODE" != "comprehensive" ]]; then
    echo "Error: Mode must be 'minimal' or 'comprehensive'"
    exit 1
fi

echo "Running $MODE integration tests for $PLATFORM..."

# Run appropriate tests based on platform and mode
if [[ "$PLATFORM" == "ios" ]]; then
    # Run iOS tests
    flutter test integration_test/app_test_ios.dart
else
    # Run Android tests
    flutter test integration_test/app_test.dart
fi

echo "Integration tests completed successfully!"
echo ""
echo "Usage:"
echo "  ./run_integration_tests.sh                      # Runs comprehensive Android tests by default"
echo "  ./run_integration_tests.sh -p ios              # Runs comprehensive iOS tests"
echo "  ./run_integration_tests.sh -m minimal          # Run minimal tests (only app launch)"
echo "  ./run_integration_tests.sh -p ios -m minimal   # Run minimal iOS tests" 