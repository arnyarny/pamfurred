import 'package:flutter/material.dart';
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

// Provider to hold the page controller
final pageControllerProvider = Provider<PageController>((ref) {
  return PageController();
});

// Provider to manage the selected tab index (in the ServiceProviderScreen)
final appointmentIdProvider = StateProvider<String>((ref) => '');

// Provider to manage the selected tab index (in the ServiceProviderScreen)
final selectedTabProvider = StateProvider<int>((ref) => 0);

// Provider to hold the selected pet profile id
final selectedPetIdProvider = StateProvider<String>((ref) => '');

final selectedCategoryIndexProvider = StateProvider<int>((ref) => 0);

// Provider to hold the index of the bottom navbar
final bottomNavBarIndexProvider = StateProvider<int>((ref) => 0);
