import 'package:flutter_riverpod/flutter_riverpod.dart';

// Handle the appbar and bottom nav bar visibility in home screen
class VisibilityState extends StateNotifier<bool> {
  VisibilityState() : super(true);

  // Toggles visibility based on scroll direction
  void setVisible(bool isVisible) {
    if (state != isVisible) {
      state = isVisible;
    }
  }
}

final visibilityProvider = StateNotifierProvider<VisibilityState, bool>((ref) {
  return VisibilityState();
});

// final showAddIconProvider = StateProvider<bool>((ref) => false);

// Provider to manage the selected tab index (in the ServiceProviderScreen)
final selectedTabProvider = StateProvider<int>((ref) => 0);

final selectedCategoryIndexProvider = StateProvider<int>((ref) => 0);