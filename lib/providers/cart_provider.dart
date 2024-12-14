import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/models/cart_item.dart';
import 'package:pamfurred/models/services.dart';
import 'package:pamfurred/models/packages.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class CartNotifier extends StateNotifier<Set<CartItem>> {
  CartNotifier(this.ref, this.userId) : super({});

  final Ref ref;
  final String? userId; // Store the userId for further use

  // Watch selected service/package type, i.e., Home service or In-clinic
  String get selectedServicePackageType =>
      ref.watch(selectedAppointmentPackageServiceTypeProvider);

  // Watch selected pet type and pet weight for appointment
  String get selectedPetType => ref.watch(selectedAppointmentPetTypeProvider);
  double? get selectedPetWeight => ref.watch(selectedAppointmentPetWeightProvider);

  // Helper to get a unique set of provider IDs in the cart
  Set<String> get uniqueProviderIds {
    return state.map((item) => item.serviceProviderId).toSet();
  }

  // Check for provider conflicts
  bool _hasProviderConflict(Service service) {
    for (final item in state) {
      if (item.serviceProviderId != service.serviceProviderId) {
        return true; // Conflict found: Different service providers
      }
    }
    return false;
  }

  bool _hasProviderPackageConflict(Package package) {
    for (final item in state) {
      if (item.serviceProviderId != package.serviceProviderId) {
        return true; // Conflict found: Different service providers
      }
    }
    return false;
  }

  // Check for size (weight) conflicts based on pet weight
  bool _hasWeightConflict(Service service) {
    if (selectedPetWeight == null) return false;

    final minSize = service.minWeight;
    final maxSize = service.maxWeight;

    return selectedPetWeight! < minSize || selectedPetWeight! > maxSize;
  }

  bool _hasWeightPackageConflict(Package package) {
    if (selectedPetWeight == null) return false;

    final minSize = package.minWeight;
    final maxSize = package.maxWeight;

    return selectedPetWeight! < minSize || selectedPetWeight! > maxSize;
  }

  // Check for type conflicts
  bool _hasTypeConflict(Service service) {
    return !service.servicePackageType.any(
      (type) => selectedServicePackageType.contains(type),
    );
  }

  bool _hasTypePackageConflict(Package package) {
    return !package.servicePackageType.any(
      (type) => selectedServicePackageType.contains(type),
    );
  }

  // Add a service to the cart
  void addService(Service service, BuildContext context) {
    if (_hasProviderConflict(service)) {
      _showProviderConflictDialog(context);
      return;
    }
    if (_hasWeightConflict(service)) {
      _showWeightConflictDialog(context);
      return;
    }
    if (_hasTypeConflict(service)) {
      _showTypeConflictDialog(context);
      return;
    }
    if (!state.any((item) =>
        item.id == service.id &&
        item.servicePackageDetailsId == service.servicePackageDetailsId)) {
      state = {...state, service};
    }
  }

  // Add a package to the cart
  void addPackage(Package package, BuildContext context) {
    if (_hasProviderPackageConflict(package)) {
      _showProviderConflictDialog(context);
      return;
    }
    if (_hasWeightPackageConflict(package)) {
      _showWeightConflictDialog(context);
      return;
    }
    if (_hasTypePackageConflict(package)) {
      _showTypeConflictDialog(context);
      return;
    }
    if (!state.any((item) =>
        item.id == package.id &&
        item.servicePackageDetailsId == package.servicePackageDetailsId)) {
      state = {...state, package};
    }
  }

  // Show a provider conflict dialog
  void _showProviderConflictDialog(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      animType: QuickAlertAnimType.slideInUp,
      title: 'Oops...',
      text: 'You can only book services or packages from the same provider.',
    );
  }

  // Show a weight conflict dialog
  void _showWeightConflictDialog(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      animType: QuickAlertAnimType.slideInUp,
      title: 'Weight Conflict',
      text: 'The selected pet weight is outside the allowed range for this service or package.',
    );
  }

  // Show a type conflict dialog
  void _showTypeConflictDialog(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      animType: QuickAlertAnimType.slideInUp,
      title: 'Warning',
      text: 'The service or package type must match the selected type.',
    );
  }

  // Remove a service from the cart
  void removeService(Service service) {
    state = state
        .where((item) =>
            item.id != service.id ||
            item.servicePackageDetailsId != service.servicePackageDetailsId)
        .toSet();
  }

  // Remove a package from the cart
  void removePackage(Package package) {
    state = state
        .where((item) =>
            item.id != package.id ||
            item.servicePackageDetailsId != package.servicePackageDetailsId)
        .toSet();
  }

  // Clear the cart
  void clearCart() {
    state = {};
  }
}

// Create a provider for CartNotifier that also listens for the userIdProvider
final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, Set<CartItem>>((ref) {
  final userId = ref.watch(userIdProvider); // Watch the current user ID
  return CartNotifier(ref, userId);
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
