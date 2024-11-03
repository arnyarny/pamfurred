import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/models/cart_item.dart';
import 'package:pamfurred/models/services.dart';
import 'package:pamfurred/models/packages.dart';

// Notifier provider to manage the cart
class CartNotifier extends StateNotifier<Set<CartItem>> {
  CartNotifier(this.context) : super({});

  final BuildContext context;

  // Helper to get a unique set of provider IDs in the cart
  Set<String> get uniqueProviderIds {
    return state.map((item) => item.serviceProviderId).toSet();
  }

  // Add a Service to the cart
  void addService(Service service) {
    // Check for provider conflict
    if (uniqueProviderIds.isNotEmpty &&
        !uniqueProviderIds.contains(service.serviceProviderId)) {
      _showProviderConflictDialog();
      return;
    }

    // Add the service if no conflict
    if (!state.any((item) => item.id == service.id)) {
      state = {...state, service};
    }
  }

  // Add a Package to the cart
  void addPackage(Package package) {
    // Check for provider conflict
    if (uniqueProviderIds.isNotEmpty &&
        !uniqueProviderIds.contains(package.serviceProviderId)) {
      _showProviderConflictDialog();
      return;
    }

    // Add the package if no conflict
    if (!state.any((item) => item.id == package.id)) {
      state = {...state, package};
    }
  }

// Show conflict dialog when trying to add items from a different provider
  void _showProviderConflictDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set your desired background color
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(primaryBorderRadius), // Adjust the border radius
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('Error',
                  style: TextStyle(
                      fontWeight: boldWeight,
                      overflow: TextOverflow.ellipsis,
                      fontSize: titleFont)),
            ],
          ),
          content: const Text(
            'You can only book services or packages from one service provider at a time.',
            style: TextStyle(
              fontSize: regularText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Remove a Service from the cart
  void removeService(Service service) {
    state = state.where((item) => item.id != service.id).toSet();
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
  final context = ref.read(appContextProvider);
  return CartNotifier(context);
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
