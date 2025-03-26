import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/models/location_time_summary.dart';

import 'mocks/model_mocks.dart';
import 'mocks/provider_mocks.dart';
import 'mocks/service_mocks.dart';

void registerAllFallbackValues() {
  registerFallbackValues();
  registerModelFallbackValues();
  registerServiceFallbackValues();
}

LocationTimeSummary createTestLocationSummary() {
  return TestLocationTimeSummary(
    date: DateTime(2023, 5, 10),
    locationDurations: {
      'Office': 330 * 60, // 5h 30m in seconds
      'Home': 135 * 60, // 2h 15m in seconds
      'Café': 45 * 60, // 45m in seconds
    },
    formattedDurations: {
      'Office': '5h 30m',
      'Home': '2h 15m',
      'Café': '0h 45m',
    },
  );
}

Widget createTestableWidget(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

// Helper to dump the widget tree for debugging
void dumpWidgetTree(WidgetTester tester) {
  debugPrint('Widget tree:');
  debugPrint('${tester.allWidgets}');

  for (final widget in tester.allWidgets) {
    if (widget is ElevatedButton) {
      debugPrint('Found ElevatedButton: $widget');
    }
  }
}
