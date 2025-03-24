import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_practice/providers/main_tab_view/main_tab_view_provider.dart';

void main() {
  late MainTabViewProvider provider;

  setUp(() {
    provider = MainTabViewProvider();
  });

  group('MainTabViewProvider', () {
    test('initial state should be first tab', () {
      expect(provider.selectedIndex, 0);
    });

    test('changeTab should update current tab index', () {
      provider.changeTab(1);
      expect(provider.selectedIndex, 1);

      provider.changeTab(2);
      expect(provider.selectedIndex, 2);
    });

    test('changeTab should not update if index is out of bounds', () {
      provider.changeTab(1);
      expect(provider.selectedIndex, 1);

      provider.changeTab(2);
      expect(provider.selectedIndex, 2);
    });

    test('changeTab should notify listeners', () {
      var notified = false;
      provider.addListener(() => notified = true);

      provider.changeTab(1);
      expect(notified, true);
    });
  });
}