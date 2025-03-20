import 'package:flutter/material.dart';
import 'package:tracking_practice/providers/main_tab_view/main_tab_view_state.dart';

class MainTabViewProvider extends ChangeNotifier {
  MainTabViewState _state = MainTabViewState.initial();

  MainTabViewState get state => _state;

  void changeTab(int index) {
    _state = _state.copyWith(selectedIndex: index);
    notifyListeners();
  }
}