import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/models/cart_item.dart';
import 'package:pamfurred/models/services.dart';
import 'package:pamfurred/models/packages.dart';

// Notifier provider to manage the cart
class CartNotifier extends StateNotifier<Set<CartItem>> {
  CartNotifier() : super({});

  // Add a Service to the cart
  void addService(Service service) {
    if (!state.any((item) => item.id == service.id)) {
      state = {
        ...state,
        service
      }; // Directly add Service since it is a CartItem
    }
  }

  // Remove a Service from the cart
  void removeService(Service service) {
    state = state.where((item) => item.id != service.id).toSet();
  }

  // Add a Package to the cart
  void addPackage(Package package) {
    if (!state.any((item) => item.id == package.id)) {
      state = {
        ...state,
        package
      }; // Directly add Package since it is a CartItem
    }
  }

  // Remove a Package from the cart
  void removePackage(Package package) {
    state = state.where((item) => item.id != package.id).toSet();
  }

  // Clear the entire cart
  void clearCart() {
    state = {};
  }
}

// Create a provider for CartNotifier
final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, Set<CartItem>>((ref) {
  return CartNotifier();
});

// Provider to calculate the total price of all items in the cart
final cartTotalProvider = Provider<num>((ref) {
  final cartItems = ref.watch(cartNotifierProvider);
  num total = 0;

  for (var item in cartItems) {
    total += item.price; // Make sure CartItem has a price property
  }

  return total;
});
