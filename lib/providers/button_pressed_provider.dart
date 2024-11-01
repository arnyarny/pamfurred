import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create a StateNotifier to manage the pressed state
class ButtonPressedNotifier extends StateNotifier<bool> {
  ButtonPressedNotifier() : super(false);

  void setPressed(bool isPressed) {
    state = isPressed;
  }
}

// Declare the StateNotifierProvider
final buttonPressedProvider = StateNotifierProvider<ButtonPressedNotifier, bool>((ref) {
  return ButtonPressedNotifier();
});
