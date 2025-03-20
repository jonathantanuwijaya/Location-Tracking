class MainTabViewState {
  MainTabViewState({required this.selectedIndex});
  final int selectedIndex;

  factory MainTabViewState.initial() => MainTabViewState(selectedIndex: 0);

  MainTabViewState copyWith({int? selectedIndex}) =>
      MainTabViewState(selectedIndex: selectedIndex ?? this.selectedIndex);
}