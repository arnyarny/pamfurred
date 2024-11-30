import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/models/cart_item.dart';
import 'package:pamfurred/models/services.dart';
import 'package:pamfurred/models/packages.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class CartNotifier extends StateNotifier<Set<CartItem>> {
  CartNotifier(this.userId) : super({});

  final String? userId; // Store the userId for further use

  // Helper to get a unique set of provider IDs in the cart
  Set<String> get uniqueProviderIds {
    return state.map((item) => item.serviceProviderId).toSet();
  }

  // Check for conflicts based on service attributes
  bool _isConflict(Service service) {
    for (final item in state) {
      if (item.serviceProviderId != service.serviceProviderId) {
        return true; // Conflict found: Different service providers
      }
      bool petTypeConflict =
          item.petType.toSet().intersection(service.petType.toSet()).isEmpty;
      if (petTypeConflict) {
        return true; // Conflict found: No matching pet types
      }
    }
    return false; // No conflict found
  }

  bool _isPackageConflict(Package package) {
    for (final item in state) {
      if (item.serviceProviderId != package.serviceProviderId) {
        return true; // Conflict found: Different service providers
      }
      bool petTypeConflict =
          item.petType.toSet().intersection(package.petType.toSet()).isEmpty;
      if (petTypeConflict) {
        return true; // Conflict found: No matching pet types
      }
    }
    return false; // No conflict found
  }

  void addService(Service service, BuildContext context) {
    if (_isConflict(service)) {
      _showProviderConflictDialog(context);
      return;
    }
    if (!state.any((item) => item.id == service.id)) {
      state = {...state, service};
    }
  }

  void addPackage(Package package, BuildContext context) {
    if (_isPackageConflict(package)) {
      _showProviderConflictDialog(context);
      return;
    }
    if (!state.any((item) => item.id == package.id)) {
      state = {...state, package};
    }
  }

  void _showProviderConflictDialog(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...',
      text: 'You can only book services or packages from the same provider.',
    );
  }

  void removeService(Service service) {
    state = state.where((item) => item.id != service.id).toSet();
  }

  void removePackage(Package package) {
    state = state.where((item) => item.id != package.id).toSet();
  }

  void clearCart() {
    state = {};
  }
}

// Create a provider for CartNotifier that also listens for the userIdProvider
final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, Set<CartItem>>((ref) {
  final userId = ref.watch(userIdProvider); // Watch the current user ID
  return CartNotifier(userId);
});

// Provider to calculate the total price of all items in the cart
final cartTotalProvider = Provider<num>((ref) {
  final cartItems = ref.watch(cartNotifierProvider);
  num total = 0;

  for (var item in cartItems) {
    total += item.price;
  }

  return total;
});
